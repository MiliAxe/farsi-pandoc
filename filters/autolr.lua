-- autolr.lua (Final "Token Splitter" Version)

-- 1. Helper: Is this element strictly Latin text?
local function is_latin(el)
  if el.t == 'Str' and el.text:match("[A-Za-z]") then return true end
  if el.t == 'Code' then return true end
  if el.t == 'Math' then return true end
  return false
end

-- 2. Helper: Is this punctuation or number?
local function is_punctuation_or_number(el)
  return el.t == 'Str' and el.text:match("^[0-9%p]+$")
end

function Inlines(inlines)
  local result = {}
  local buffer = {}         
  local pending_spaces = {} 

  -- Flush buffer to result wrapped in \lr{}
  local function flush_buffer()
    if #buffer > 0 then
      table.insert(result, pandoc.RawInline('latex', '\\lr{'))
      for _, item in ipairs(buffer) do table.insert(result, item) end
      table.insert(result, pandoc.RawInline('latex', '}'))
      buffer = {}
    end
  end

  -- Move pending spaces into the buffer (they belong to English)
  local function commit_pending_spaces()
    for _, s in ipairs(pending_spaces) do table.insert(buffer, s) end
    pending_spaces = {}
  end

  -- Move pending spaces to result (they belong to Farsi)
  local function reject_pending_spaces()
    for _, s in ipairs(pending_spaces) do table.insert(result, s) end
    pending_spaces = {}
  end

  for _, el in ipairs(inlines) do
    
    -- Recursion for Bold/Italic
    if el.t == 'Emph' or el.t == 'Strong' then
      flush_buffer()
      reject_pending_spaces()
      el.content = Inlines(el.content)
      table.insert(result, el)
      
    else
      local latin_item = is_latin(el)
      local punct_item = is_punctuation_or_number(el)
      local space_item = (el.t == 'Space' or el.t == 'SoftBreak')

      if latin_item then
        commit_pending_spaces()
        table.insert(buffer, el)

      elseif punct_item and #buffer > 0 then
        -- [THE FIX] Token Splitting Logic
        -- We look for a split: 'prefix' (stuff before closer) + 'suffix' (the closer)
        -- Pattern: ^(.-) means non-greedy match for prefix
        --          ([%)%]%}%»]+)$ means match one or more closers at the end
        local prefix, suffix = el.text:match("^(.-)([%)%]%}%»]+)$")

        if suffix then
          -- We found a closer at the end (e.g., "!)" or ".)" or just ")")
          
          -- 1. If there was a prefix (like "!" in "!)"), keep it inside English
          if #prefix > 0 then
             commit_pending_spaces()
             table.insert(buffer, pandoc.Str(prefix))
          end

          -- 2. Close the English block NOW
          flush_buffer()
          
          -- 3. Spaces before the closer go to Farsi (usually empty if prefix existed)
          reject_pending_spaces()
          
          -- 4. Print the closer (")") outside
          table.insert(result, pandoc.Str(suffix))
        else
          -- No closer found (e.g. "..." or "!!" or "1.2"), keep inside English
          commit_pending_spaces()
          table.insert(buffer, el)
        end

      elseif space_item and #buffer > 0 then
        table.insert(pending_spaces, el)

      else
        flush_buffer()
        reject_pending_spaces()
        table.insert(result, el)
      end
    end
  end

  flush_buffer()
  reject_pending_spaces()
  
  return result
end