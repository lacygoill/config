vim9script

def Cache(cache_file: string) #{{{1
    if exists(':Man') != 2
        echomsg 'need :Man to compute parameters, but it''s not installed'
        return
    endif

    var parameters_db: dict<list<dict<any>>>
    var match_param: string = '^\s\{7}\%(\S\+=,\=\s*\)*$'

    # List of man pages where systemd parameters are documented:{{{
    #
    #     :Man systemd.dnssd(5)
    #     :Man systemd.exec(5)
    #     :Man systemd.kill(5)
    #     :Man systemd.link(5)
    #     :Man systemd.mount(5)
    #     :Man systemd.netdev(5)
    #     :Man systemd.network(5)
    #     :Man systemd.nspawn(5)
    #     :Man systemd.path(5)
    #     :Man systemd.resource-control(5)
    #     :Man systemd.scope(5)
    #     :Man systemd.service(5)
    #     :Man systemd.socket(5)
    #     :Man systemd.swap(5)
    #     :Man systemd.timer(5)
    #     :Man systemd.unit(5)
    #}}}
    # We ignore device units.{{{
    #
    # You'll never write a file for such a unit.
    #
    #     $ locate '*.device'
    #     no output
    #
    # Those are meant to be created dynamically at runtime:
    #
    #    > systemd will dynamically create device units for all kernel devices
    #    > that are marked with the "systemd" udev tag (by default all block and
    #    > network devices, and a few others).
    #
    # Source: `man systemd.device /DESCRIPTION/;/dynamically`
    #}}}
    var topics =<< trim END
        dnssd
        exec
        kill
        link
        mount
        netdev
        network
        nspawn
        path
        resource-control
        scope
        service
        socket
        swap
        timer
        unit
    END

    for topic: string in topics
        execute $'Man systemd.{topic}'
        var heading: string
        var subheading: string
        var man_page: string = bufname('%')
            ->substitute('.*//systemd\.\|(\d\+)', '', 'g')
        var in_synopsis: bool
        var file_extensions: list<string>
        var sections: list<string>
        for line: string in getline(1, '$')
            if line =~ '^\S'
                heading = line
                subheading = ''
                in_synopsis = line == 'SYNOPSIS'

                if man_page == 'exec'
                    if ['PATHS', 'CREDENTIALS', 'CAPABILITIES', 'MANDATORY ACCESS CONTROL']->index(heading) >= 0
                        sections = ['service']
                    else
                        sections = ['mount', 'service', 'socket', 'swap']
                    endif
                elseif man_page == 'dnssd'
                    sections = ['service']
                elseif man_page == 'kill'
                    sections = ['mount', 'scope', 'service', 'socket', 'swap']
                elseif man_page == 'resource-control'
                    sections = ['mount', 'scope', 'service', 'slice', 'socket', 'swap']
                elseif heading =~ '^\[[A-Z0-9]*\] *SECTION *OPTIONS'
                    sections = [heading
                        ->matchstr('\[[A-Z0-9]*\]')
                        ->trim('[]')]
                elseif man_page == topic
                    sections = [topic]
                endif

                continue
            elseif line =~ '^\s\{3}\S'
                subheading = line->trim()
                continue
            endif

            if in_synopsis
            #     service.service, socket.socket, device.device, mount.mount,
            && line =~ '^\s*\%([a-z_/]\+\.[a-z]\+,\=\s*\)\+$'
                line->substitute('[a-z/]\+\.\zs[a-z]\+',
                    () => !!file_extensions->add(submatch(0)), 'g')
            endif
            file_extensions->sort()->uniq()

            if line =~ match_param
            # Useful to not match sth like `x-systemd.requires=`.{{{
            #
            # The latter can be found at `man systemd.mount(5)`.
            # However, that's not  a parameter.  This is meant to  be written in the
            # value of the `Options` parameter.  Example:
            #
            #     Options=defaults,x-systemd.requires-mounts-for=/test
            #                      ^----------------------------^
            #}}}
            && line =~ '^\s*[A-Z]'
            && heading !~ 'deprecated'
                var parameters: list<string> = line
                    ->substitute('[[:blank:]=,]', ' ', 'g')
                    ->split('\s\+')
                for param: string in parameters
                    var pum_description: string = $'{man_page}: {heading}: {subheading}'
                        ->trim(': ')
                    var context: dict<any> = {
                        sections: sections,
                        pum_description: pum_description,
                        file_extensions: file_extensions,
                    }
                    if !parameters_db->has_key(param)
                        parameters_db[param] = [context]
                    else
                        parameters_db[param]->add(context)
                    endif
                endfor
            endif
        endfor
    endfor

    [parameters_db->json_encode()]
        ->writefile(cache_file)

    enew
    only
    var msg: string = $'systemd parameters have been cached in {cache_file}'
    echowindow msg
enddef
#}}}1

const dir: string = $'{expand('<script>:h')}'
dir->mkdir('p')
$'{dir}/parameters'->Cache()
