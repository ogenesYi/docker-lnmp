-- 用户跟踪cookie名为__utrace
local uid = ngx.var.cookie___utrace
if not uid then
    -- 如果没有则生成一个跟踪cookie，算法为md5(时间戳+IP+客户端信息)
    uid = ngx.md5(ngx.now() .. ngx.var.remote_addr .. ngx.var.http_user_agent)
end
ngx.header['Set-Cookie'] = { '__utrace=' .. uid .. '; path=/' }

local params = ngx.var.args
-- base64解码
local un_log = ''
if ngx.var.arg_log then
    un_log = ngx.escape_uri(ngx.decode_base64(ngx.var.arg_log))
end

if ngx.var.arg_type == 'search' then
    -- 通过subrequest到/user_behavior_search记录日志，将参数和用户跟踪cookie带过去
    ngx.location.capture('/user_behavior_search?' .. params .. '&utrace=' .. uid .. '&un_log=' .. un_log)
elseif ngx.var.arg_type == 'click' then
    -- 通过subrequest到/user_behavior_click，将参数和用户跟踪cookie带过去
    ngx.location.capture('/user_behavior_click?' .. params .. '&utrace=' .. uid .. '&un_log=' .. un_log)
elseif ngx.var.arg_type == 'browsing' then
    -- 通过subrequest到/user_behavior_browsing，将参数和用户跟踪cookie带过去
    ngx.location.capture('/user_behavior_browsing?' .. params .. '&utrace=' .. uid .. '&un_log=' .. un_log)
else
    ngx.location.capture('/user_behavior?' .. params .. '&utrace=' .. uid .. '&un_log=' .. un_log)
end
