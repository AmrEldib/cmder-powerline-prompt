local   function get_virtual_env(env_var)
            env_path = clink.get_env(env_var)
            if env_path then
                return env_path
            end
            return false
        end

---
 -- add conda env name 
---
local   function conda_prompt_filter()
            -- add in python virtual env name
            local python_env = get_virtual_env('CONDA_DEFAULT_ENV')
            if venv then
                local venv_short = string.match(venv, "[^\\/:]+$")
                clink.prompt.value = clink.prompt.value.."["..venv_short.."] "
            end
        end

---
 -- add virtual env name 
---
local   function venv_prompt_filter()
            -- add in virtual env name
            local venv = get_virtual_env('VIRTUAL_ENV')
            if venv then
                local venv_short = string.match(venv, "[^\\/:]+$")
                clink.prompt.value = clink.prompt.value.."["..venv_short.."] "
            end
        end

-- register the filters
clink.prompt.register_filter(conda_prompt_filter, 95)
clink.prompt.register_filter(venv_prompt_filter, 95)