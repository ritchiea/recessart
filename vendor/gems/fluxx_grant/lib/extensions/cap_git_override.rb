require 'capistrano/recipes/deploy/strategy/remote_cache'
require 'capistrano/recipes/deploy/scm/git'

module Capistrano
  module Deploy
    module Strategy
      class FluxxRemoteCache < RemoteCache
        def deploy!
          update_repository_cache
          update_submodules
          copy_repository_cache
        end
        
        def update_submodules
          logger.trace "updating the cached checkout on all servers"
          command = source.submodule_checkout revision, repository_cache
          scm_run(command)
        end
        
      end
    end
    
    module SCM
      class FluxxGit < Git
        def command
          'git'
        end
        
        def submodule_checkout revision, destination
          git    = command
          # Handle the case in which there is an alternate .gitmodules for capistrano
          execute = []
          execute << "cd #{destination}"
          execute << "if [ -f #{destination}/.gitmodules_capistrano ]; then cp #{destination}/.gitmodules_capistrano #{destination}/.gitmodules ;fi"
          execute << "#{git} submodule #{verbose} init"
          execute << "for mod in `#{git} submodule status | awk '{ print $2 }'`; do #{git} config -f .git/config submodule.${mod}.url `#{git} config -f .gitmodules --get submodule.${mod}.url` && echo Synced $mod; done"
          execute << "#{git} submodule #{verbose} sync"
          execute << "#{git} submodule #{verbose} update --init --recursive"

          execute.join(" && ")
        end
        
      end
    end
  end
end
