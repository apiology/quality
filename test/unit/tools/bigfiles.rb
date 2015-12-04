module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module BigFiles
        def bigfiles_expected_args
          "--glob '{Dockerfile,Rakefile,{*,.*}.{rb,rake,gemspec,js,swift,cpp,c,java,py,clj,cljs,scala,yml,sh,json},{app,config,db,feature,lib,spec,src,test,www}/**/{*,.*}.{rb,rake,gemspec,js,swift,cpp,c,java,py,clj,cljs,scala,yml,sh,json}}'"
        end

        def expect_bigfiles_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('bigfiles',
                                { args: bigfiles_expected_args },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
