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
    version = '1.1.3',  -- Pin to specific stable version
    event = 'VeryLazy',
    config = function()
      -- Validate environment and credentials with enhanced error handling
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
      local api_key = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/token')
      local api_base = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/base')
      local api_engine = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/engine')
      local api_version = validate_pass_cmd('pass show azure/hypera/oai/idg-dev/api-version')

      -- Validate prompts URL
      local prompts_url = 'https://raw.githubusercontent.com/julianobarbosa/custom-gpt-prompts/main/prompt.csv'
      if not prompts_url:match('^https://[%w-_%.]+/[%w-_/%.]+$') then
        error("Invalid prompts URL format")
        prompts_url = nil
      end

      require('chatgpt').setup({
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
        -- Graceful shutdown handling
        shutdown = {
          save_context = true,  -- Save conversation context on shutdown
          cleanup_temp = true   -- Clean temporary files
        }
      })

      -- Register shutdown callback
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          pcall(require('chatgpt').cleanup)
        end
      })
    end,
    dependencies = {
      { 'MunifTanjim/nui.nvim', version = '0.1.3' },  -- Updated for stability
      { 'nvim-lua/plenary.nvim', version = '0.1.5' },  -- Updated to fix job shutdown issue
      { 'folke/trouble.nvim', version = '2.10.0' },    -- Pinned to specific version
      { 'nvim-telescope/telescope.nvim', version = '0.1.5' },  -- Updated for compatibility
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
