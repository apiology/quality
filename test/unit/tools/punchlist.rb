module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Punchlist
        def punchlist_expected_args
          "--glob '{Rakefile,{src,app,lib,test,spec,feature}/**/*." \
          "{rb,rake,swift,cpp,c,java,py,clj,cljs,scala,js}}'"
        end

        def expect_punchlist_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('punchlist',
                                { args: punchlist_expected_args },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
