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

  describe 'PATCH /api/v1/tasks/:id' do
    let!(:task) { create(:task, title: 'Old Title', description: 'Old Description', status: :todo, position: 1) }
    let(:valid_params) { { task: { title: 'New Title', description: 'New Description', status: :done, position: 1 } } }
    let(:invalid_params) { { task: { title: '', description: 'New Description', status: :done, position: 1 } } }

    context 'パラメータ有効な場合' do
      it 'タスクを更新できる' do
        patch :update, params: valid_params.merge(id: task.id)
        task.reload
        expect(task.title).to eq('New Title')
        expect(task.description).to eq('New Description')
        expect(task.status).to eq('done')
        expect(task.position).to eq(1)
      end

      it '200を返す' do
        patch :update, params: valid_params.merge(id: task.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'パラメータが無効な場合' do
      it 'タスクを更新できない' do
        original_title = task.title
        patch :update, params: invalid_params.merge(id: task.id)
        task.reload
        expect(task.title).to eq(original_title)
      end

      it '422を返す' do
        patch :update, params: invalid_params.merge(id: task.id)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        patch :update, params: invalid_params.merge(id: task.id)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:id' do
    let!(:task1) { Task.create!(title: 'Task 1', status: :todo, position: 1) }
    let!(:task2) { Task.create!(title: 'Task 2', status: :todo, position: 2) }
    let!(:task3) { Task.create!(title: 'Task 3', status: :todo, position: 3) }

    context 'タスクが存在する場合' do
      it 'タスクを削除できる' do
        expect { delete :destroy, params: { id: task1.id } }.to change(Task, :count).by(-1)
      end

      it '200を返す' do
        delete :destroy, params: { id: task1.id }
        expect(response).to have_http_status(:ok)
      end

      it 'タスクのリストを返す' do
        delete :destroy, params: { id: task1.id }

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json[:tasks].size).to eq(2)
        expect(json[:tasks][0][:position]).to eq(1)
        expect(json[:tasks][0][:title]).to eq(task2.title)
        expect(json[:tasks][1][:position]).to eq(2)
        expect(json[:tasks][1][:title]).to eq(task3.title)
      end
    end

    context 'タスクが存在しない場合' do
      it '404を返す' do
        delete :destroy, params: { id: 0 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/tasks/reorder' do
    let!(:task1) { create(:task, status: :todo, position: 1) }
    let!(:task2) { create(:task, status: :todo, position: 2) }
    let!(:task3) { create(:task, status: :todo, position: 3) }
    let(:valid_params) { { task: { id: task1.id, status: 'done', position: 1 } } }
    let(:invalid_params) { { task: { id: task1.id, status: 'invalid_status', position: 2 } } }

    context 'パラメータが有効な場合' do
      it 'ステータスと位置を更新できる' do
        post :reorder, params: valid_params
        task1.reload
        task2.reload
        task3.reload
        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)
        expect(task1.status).to eq('done')
        expect(task1.position).to eq(1)
      end

      it '200を返す' do
        post :reorder, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'タスクのリストを返す' do
        get :reorder, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['tasks'].size).to eq(3)
      end
    end

    context 'パラメータが無効な場合' do
      it 'タスクのステータスを更新できない' do
        original_status = task1.status
        post :reorder, params: invalid_params
        task1.reload
        expect(task1.status).to eq(original_status)
      end

      it '422を返す' do
        post :reorder, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        post :reorder, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
