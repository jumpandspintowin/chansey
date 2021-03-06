module Chansey
    module IRC
        module RemoteProcedures
            def on_restart(request)
                reason = request.opts("reason")
                @controller.restart(*reason)
            end

            def on_networkcreate(request)
                params = {
                    'name' => String,
                    'auto' => Boolean,
                    'servers' => Array,
                    'nick' => Array,
                    'fullname' => String,
                    'channels' => Array
                }
                return if !verify_params(request, params)
                if !@controller.new_network(request.opts('name'))
                    request.failure(:reason => 'Network exists')
                else
                    net = @controller.networks[request.opts('name')]
                    net.connect
                    request.success
                end
            end

            def on_networkjoin(request)
                params = {
                    'name' => String
                }
                return if !verify_params(request, params)
                net = @controller.networks[request.opts('name')]
                if net.nil?
                    request.failure(:reason => 'Network does not exist')
                elsif net.server
                    request.failure(:reason => 'Already connected')
                else
                    net.connect
                end
            end


            def on_raw(request)
                params = {
                    'network' => String,
                    'line'    => String
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.raw(request.opts("line"))
                request.success
            end

            def on_nick(request)
                params = {
                    'network' => String,
                    'nick'    => String
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.nick(request.opts("nick"))
                request.success
            end

            def on_join(request)
                # Channels should be an array of hashes
                # channel = {
                #     <channel-name> => <password>
                # }
                params = {
                    'network' => String,
                    'channels' => Hash
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.join(request.opts("channels").keys, request.opts("channels").values)
                request.success
            end

            def on_part(request)
                params = {
                    'network' => String,
                    'channels' => Array
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.part(request.opts("channels"), request.opts("msg"))
                request.success
            end

            def on_mode(request)
                params = {
                    'network' => String,
                    'channel' => String,
                    'modes' => String
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.mode(request.opts("channel"), request.opts("modes"), request.opts("operands"))
                request.success
            end

            def on_topic(request)
                params = {
                    'network' => String,
                    'channel' => String,
                    'topic'   => String
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.topic(request.opts("channel"), request.opts("topic"))
                request.success
            end

            def on_invite(request)
                params = {
                    'network' => String,
                    'channel' => String,
                    'nick'    => String
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.invite(request.opts("nick"), request.opts("channel"))
                request.success
            end

            def on_kick(request)
                params = {
                    'network' => String,
                    'channels' => Array,
                    'nicks'    => Array 
                }

                return if !verify_params(request, params)
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.invite(request.opts("channels"), request.opts("nicks"), request.opts("msg"))
                request.success
            end


            def on_privmsg(request)
                params = {
                    'channel' => String,
                    'network' => String,
                    'msg'     => String
                }

                # verify opts exist
                return if !verify_params(request, params)

                # verify network exists
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.privmsg(request.opts("channel"), request.opts("msg"))
                request.success
            end

            def on_notice(request)
                params = {
                    'channel' => String,
                    'network' => String,
                    'msg'     => String
                }

                # verify opts exist
                return if !verify_params(request, params)

                # verify network exists
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.notice(request.opts("channel"), request.opts("msg"))
                request.success
            end

            def on_quit(request)
                params = {
                    'network' => String,
                }

                # verify opts exist
                return if !verify_params(request, params)

                # verify network exists
                net = @controller.networks[request.opts("network")]
                return if !verify_network(request, net)

                net.notice(request.opts("msg"))
                request.success
            end

            private
            def verify_network(request, network)
                if !network
                    request.failure( :reason => "Network does not exist" )
                    return false
                elsif !network.server
                    request.failure( :reason => "Network is not connected" )
                    return false
                else
                    return true
                end
            end
        end
    end
end
