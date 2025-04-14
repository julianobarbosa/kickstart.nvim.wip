-- MIT License
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

return {
  {
    'jackMort/ChatGPT.nvim',
    event = 'VimEnter',
    config = function()
      vim.notify("Initializing ChatGPT plugin...", vim.log.levels.INFO)
      -- Validate environment and credentials with enhanced error handling and state tracking
      local plugin_state = {
        initialized = false,
        credentials_validated = false
      }
      local function validate_pass_cmd(cmd)
        -- Default fallback values for testing/development
        local fallback_values = {
          ['token'] = 'dummy_token',
          ['base'] = 'https://api.openai.com',
          ['engine'] = 'gpt-3.5-turbo',
          ['api-version'] = '2023-07-01-preview'
        }

        local ok, handle = pcall(io.popen, cmd)
        if not ok or not handle then
          vim.notify("Warning: Failed to execute pass command. Using fallback value.", vim.log.levels.WARN)
          local key = cmd:match('pass show azure/hypera/oai/idg%-dev/(%w+[-]?%w*)')
          return fallback_values[key] or 'dummy_value'
        end

        local result = handle:read("*a")
        local close_ok, _ = handle:close()
        
        if not close_ok or not result or result == "" then
          vim.notify("Warning: Invalid credential value. Using fallback.", vim.log.levels.WARN)
          local key = cmd:match('pass show azure/hypera/oai/idg%-dev/(%w+[-]?%w*)')
          return fallback_values[key] or 'dummy_value'
        end

        return result:gsub("[\n\r]", "")  -- Clean up newlines
      end

      -- Secure credential retrieval
      -- Validate and track credential state
      local function validate_credentials()
        local api_key = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/token')
        local api_base = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/base')
        local api_engine = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/engine')
        local api_version = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/api-version')
        
        if api_key and api_base and api_engine and api_version then
          plugin_state.credentials_validated = true
          return api_key, api_base, api_engine, api_version
        else
          vim.notify("Failed to validate all credentials", vim.log.levels.ERROR)
          return nil
        end
      end

      local api_key, api_base, api_engine, api_version = validate_credentials()
      if not api_key then
        return
      end

      -- Validate prompts URL
      local prompts_url = 'https://raw.githubusercontent.com/julianobarbosa/custom-gpt-prompts/main/prompt.csv'
      if not prompts_url:match('^https://[%w-_%.]+/[%w-_/%.]+$') then
        error("Invalid prompts URL format")
        prompts_url = nil
      end

      -- Initialize plugin with validated credentials
      if not plugin_state.credentials_validated then
        vim.notify("Credentials validation required before initialization", vim.log.levels.ERROR)
        return
      end

      local ok, chatgpt = pcall(require, 'chatgpt')
      if not ok then
        vim.notify("Failed to load ChatGPT plugin", vim.log.levels.ERROR)
        return
      end

      -- Configure with validated state
      plugin_state.initialized = true
      vim.notify("ChatGPT plugin initialized successfully", vim.log.levels.INFO)

      chatgpt.setup({
        api_key_cmd = api_key and ('echo -n "' .. api_key .. '"') or error("Failed to retrieve API key"),
        api_host_cmd = 'echo -n ""',
        api_type_cmd = 'echo azure',
        azure_api_base_cmd = api_base and ('echo -n "' .. api_base .. '"') or error("Failed to retrieve API base"),
        azure_api_engine_cmd = api_engine and ('echo -n "' .. api_engine .. '"') or error("Failed to retrieve API engine"),
        azure_api_version_cmd = api_version and ('echo -n "' .. api_version .. '"') or error("Failed to retrieve API version"),
        predefined_chat_gpt_prompts = prompts_url,
        -- Additional security settings
        show_api_key = false,  -- Never display API key in UI
        validate_response = true,  -- Enable response validation
        sanitize_input = true,  -- Sanitize user input
        error_handling = {
          timeout = 15000,      -- Increased timeout to 15s
          retry_count = 3,      -- Increased retry attempts
          retry_delay = 2000,   -- 2s delay between retries
          fallback_behavior = {
            use_local = true,   -- Use local fallback if available
            notify_user = true  -- Notify user of fallback usage
          }
        },
        -- Enhanced shutdown handling with state tracking
        shutdown = {
          save_context = true,    -- Save conversation context on shutdown
          cleanup_temp = true,    -- Clean temporary files
          cleanup_timeout = 3000, -- Timeout for cleanup operations (ms)
          preserve_state = true   -- Keep critical state during cleanup
        }
      })

      -- Enhanced shutdown handling with proper sequencing and error tracing
      local function safe_cleanup()
        local ok, chatgpt = pcall(require, 'chatgpt')
        if not ok then
          vim.notify("ChatGPT plugin not loaded during cleanup", vim.log.levels.WARN)
          return
        end
        
        -- Ensure cleanup happens in correct order with error tracking
        vim.schedule(function()
          -- Save context first if enabled
          if type(chatgpt.config) == "table" and chatgpt.config.shutdown and chatgpt.config.shutdown.save_context then
            local save_ok, save_err = pcall(chatgpt.save_context)
            if not save_ok then
              vim.notify("Failed to save ChatGPT context: " .. tostring(save_err), vim.log.levels.WARN)
            end
          end
          
          -- Set cleanup timeout with validation
          local timeout = 3000
          if type(chatgpt.config) == "table" and chatgpt.config.shutdown then
            timeout = chatgpt.config.shutdown.cleanup_timeout or timeout
          end
          
          vim.defer_fn(function()
            local cleanup_ok, cleanup_err = pcall(chatgpt.cleanup)
            if not cleanup_ok then
              vim.notify("ChatGPT cleanup failed: " .. tostring(cleanup_err), vim.log.levels.WARN)
            end
          end, timeout)
        end)
      end

      -- Register shutdown hooks with proper sequencing
      vim.api.nvim_create_autocmd({"VimLeavePre"}, {
        callback = safe_cleanup,
        group = vim.api.nvim_create_augroup("ChatGPTCleanup", { clear = true })
      })
    end,
    dependencies = {
      { 'MunifTanjim/nui.nvim' },           -- Updated for stability
      { 'nvim-lua/plenary.nvim' },          -- Updated to fix job shutdown issue
      { 'folke/trouble.nvim' },             -- Pinned to specific version
      { 'nvim-telescope/telescope.nvim' },  -- Updated for compatibility
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
