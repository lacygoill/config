# ChangeLog

<https://weechat.org/files/doc/weechat/ChangeLog-devel.html>

# Release Notes

<https://weechat.org/files/releasenotes/ReleaseNotes-devel.html>

# user guide

<https://weechat.org/files/doc/stable/weechat_user.en.html>

# plugin API reference

<https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html>

# scripting guide

<https://weechat.org/files/doc/weechat/stable/weechat_scripting.en.html>

# Wiki

<https://github.com/weechat/weechat/wiki>

# FAQ

<https://weechat.org/files/doc/weechat/stable/weechat_faq.en.html>

# XDG Base Directory Specifications

<https://specs.weechat.org/specs/2021-001-follow-xdg-base-dir-spec.html>

# buffer properties

    $ xdg-open 'https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_buffer_get_integer' \
        && xdg-open 'https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_buffer_get_string' \
        && xdg-open 'https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_buffer_get_pointer' \
        && xdg-open 'https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#_buffer_set' \
    # lists of properties which you can get (read) and set (write)

# buffer variables

<https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_buffer>

To evaluate such variables:

    /eval -n ${buffer.<var>}

# window variables

<https://weechat.org/files/doc/weechat/stable/weechat_plugin_api.en.html#hdata_window>

To evaluate such variables:

    /eval -n ${window.<var>}
