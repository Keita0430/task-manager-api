require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーション' do
    subject { Task.new(title: title, description: '三角関数', status: status) }

    describe 'title' do
      let(:status) { :todo }

      context 'タイトルがnilの場合' do
        let(:title) { nil }

        it '無効' do
          expect(subject).to_not be_valid
        end
      end

      context 'タイトルが空文字の場合' do
        let(:title) { '' }

        it '無効' do
          expect(subject).to_not be_valid
        end
      end

      context 'タイトルが255文字の場合' do
        let(:title) { 'a' * 255 }

        it '有効' do
          expect(subject).to be_valid
        end
      end

      context 'タイトルが256文字の場合' do
        let(:title) { 'a' * 256 }

        it '無効' do
          expect(subject).to_not be_valid
        end
      end
    end

    describe 'status' do
      let(:title) { 'Valid Title' }

      context 'ステータスがnilの場合' do
        let(:status) { nil }

        it '無効' do
          expect(subject).to_not be_valid
        end
      end

      context 'ステータスが無効な値の場合' do
        let(:status) { 'invalid_status' }

        it '無効' do
          expect(subject).to_not be_valid
        end
      end

      context 'ステータスが有効な値の場合' do
        let(:status) { :done }

        it '有効' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
