require 'spec_helper'

describe RubyTry do
  describe 'Using it at call site' do
    context 'successful invocation' do

      let(:return_value) { 3 }

      let(:code_to_invoke) do
        a = 1
        a + 2
        return_value
      end

      it 'marks the response as success' do
        expect(Try { code_to_invoke }).to be_success
      end

      it 'returns the original return value' do
        expect(Try { code_to_invoke }.value).to eq(return_value)
      end

      it 'allows map iteration and continues returning success' do
        expect(Try { code_to_invoke }.map { |val| val * 3 }.value).to eq(9)
      end
    end

    context 'failure invocation' do

      let (:exception_to_raise) do
        RuntimeError.new("oh no")
      end

      let(:code_to_invoke) do
        raise exception_to_raise
      end

      let(:success_code_to_invoke) do
        a = 1
        a += 2
        a
      end

      it 'marks the response as failure' do
        expect(Try { code_to_invoke }).to be_failure
      end

      it 'return the errors' do
        expect(Try { code_to_invoke }.error).to eq(exception_to_raise)
      end

      it 'allows to get a default value if error' do
        expect(Try { code_to_invoke }.value_or('5')).to eq('5')
      end

      it 'allows map iteration and continues returning failure' do
        expect(Try { code_to_invoke }.map { |val| val * 3 }.value).to eq(exception_to_raise)
      end

      it 'fails if the first one succeeds but second fail' do
        expect(Try { success_code_to_invoke }.map { |_| code_to_invoke }.value).to eq(exception_to_raise)
      end
    end
  end

  describe 'wrapping methods to return Try' do
    let(:wrapped_object) do
      Class.new(Object) {

        def raiser
          raise 'WOW'
        end

        def returns_4
          4
        end

        Try :raise, :returns_4
      }.new
    end

    context 'success case' do
      it 'returns a successful try object' do
        expect(wrapped_object.returns_4).to be_success
      end
    end
  end
end
