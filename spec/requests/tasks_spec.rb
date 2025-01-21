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
    let(:valid_params) { { task: { title: '数学Ⅱ・Bの宿題', description: '三角関数', status: :todo, position: 1 } } }
    let(:invalid_params) { { task: { title: '', description: '三角関数', status: 'invalid_status', position: 1 } } }

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

  describe 'DELETE /api/v1/tasks/:id' do
    let!(:task) { create(:task) }

    context 'タスクが存在する場合' do
      it 'タスクを削除できる' do
        expect { delete :destroy, params: { id: task.id } }.to change(Task, :count).by(-1)
      end

      it '200を返す' do
        delete :destroy, params: { id: task.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'タスクが存在しない場合' do
      it '404を返す' do
        delete :destroy, params: { id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id/status_and_position' do
    let!(:task) { create(:task, status: :todo, position: 1) }
    let(:valid_params) { { task: { status: 'done', position: 2 } } }
    let(:invalid_params) { { task: { status: 'invalid_status', position: 2 } } }

    context 'パラメータが有効な場合' do
      it 'ステータスと位置を更新できる' do
        patch :update_status_and_position, params: valid_params.merge(id: task.id)
        puts response.body
        task.reload
        expect(task.status).to eq('done')
        expect(task.position).to eq(2)
      end

      it '200を返す' do
        patch :update_status_and_position, params: valid_params.merge(id: task.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'パラメータが無効な場合' do
      it 'タスクのステータスを更新できない' do
        original_status = task.status
        patch :update_status_and_position, params: invalid_params.merge(id: task.id)
        task.reload
        expect(task.status).to eq(original_status)
      end

      it '422を返す' do
        patch :update_status_and_position, params: invalid_params.merge(id: task.id)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        patch :update_status_and_position, params: invalid_params.merge(id: task.id)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
