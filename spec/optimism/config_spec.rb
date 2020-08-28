RSpec.describe Optimism::Config do
  module IncludedInAModule
    include Optimism::Config
  end

  module IncludedInAnotherModule
    include Optimism::Config

    configure_optimism do |c|
      c.add_css = false
    end
  end

  describe '::configure' do
    it 'contextualizes configuration' do
      expect(IncludedInAnotherModule.optimism_configuration).not_to eq(IncludedInAModule.optimism_configuration)
    end
  end

  context IncludedInAModule do
    describe 'the module' do
      it 'returns the :add_css option as true (default)' do
        expect(subject.add_css).to be true
      end

      it { should respond_to(:optimism_configuration) }
      it { should respond_to(:optimism_config) }
      it { should respond_to(:configure_optimism) }
      it { should respond_to(:add_css) }
      it { should respond_to(:channel) }
      it { should respond_to(:container_selector) }
      it { should respond_to(:disable_submit) }
      it { should respond_to(:emit_events) }
      it { should respond_to(:error_class) }
      it { should respond_to(:error_selector) }
      it { should respond_to(:form_class) }
      it { should respond_to(:form_selector) }
      it { should respond_to(:inject_inline) }
      it { should respond_to(:submit_selector) }
      it { should respond_to(:suffix) }
    end
  end

  describe 'comparing' do
    let(:the_module) { IncludedInAnotherModule }
    let(:the_other_module) { IncludedInAModule }

    describe 'the module' do
      it 'has its own context' do
        expect(the_module.optimism_config.instance_variable_get(:@context)).to eq(IncludedInAnotherModule)
      end

      it 'returns the :add_css option as false' do
        expect(the_module.optimism_config.add_css).to be false
      end

      context 'compared to the other module' do
        it 'has a different value for the :add_css option' do
          expect(the_module.optimism_config.add_css).not_to eq the_other_module.optimism_config.add_css
        end
      end
    end
  end
end