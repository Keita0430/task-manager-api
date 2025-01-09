require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  describe 'GET /api/v1/tasks' do
    let!(:tasks) { create_list(:task, 3) }

    it 'タスクのリストを返す' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['tasks'].size).to eq(3)
    end
  end

  describe 'POST /api/v1/tasks' do
    let(:valid_params) { { task: { title: '数学Ⅱ・Bの宿題', description: '三角関数' } } }
    let(:invalid_params) { { task: { title: '', description: '三角関数' } } }

    context 'パラメータ有効な場合' do
      it 'タスクを作成できる' do
        expect { post :create, params: valid_params }.to change(Task, :count).by(1)
      end

      it '201を返す' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'パラメータが無効な場合' do
      it 'タスクを作成できない' do
        expect { post :create, params: invalid_params }.to_not change(Task, :count)
      end

      it '422を返す' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
