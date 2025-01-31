require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :request do
  describe 'GET /api/v1/tasks' do
    let!(:tasks) { create_list(:task, 3) }

    it 'タスクのリストを返す' do
      get api_v1_tasks_path
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['tasks'].size).to eq(3)
    end
  end

  describe 'POST /api/v1/tasks' do
    subject { post api_v1_tasks_path, params: params }

    context 'パラメータ有効な場合' do
      let(:params) { { task: { title: '数学Ⅱ・Bの宿題', description: '三角関数', status: :todo, position: 1 } } }

      it 'タスクを作成できる' do
        expect { subject }.to change(Task, :count).by(1)
      end

      it '201を返す' do
        subject
        expect(response).to have_http_status(:created)
      end
    end

    context 'パラメータが無効な場合' do
      let(:params) { { task: { title: '', description: '三角関数', status: 'invalid_status', position: 1 } } }

      it 'タスクを作成できない' do
        expect { subject }.to_not change(Task, :count)
      end

      it '422を返す' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        subject
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id' do
    let!(:task) { create(:task, title: 'Old Title', description: 'Old Description', status: :todo, position: 1) }
    subject { patch api_v1_task_path(task), params: params }

    context 'パラメータ有効な場合' do
      let(:params) { { task: { title: 'New Title', description: 'New Description', status: :done, position: 1 } } }

      it 'タスクを更新できる' do
        subject
        task.reload
        expect(task.title).to eq('New Title')
        expect(task.description).to eq('New Description')
        expect(task.status).to eq('done')
        expect(task.position).to eq(1)
      end

      it '200を返す' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context 'パラメータが無効な場合' do
      let(:params) { { task: { title: '', description: 'New Description', status: :done, position: 1 } } }

      it 'タスクを更新できない' do
        original_title = task.title
        subject
        task.reload
        expect(task.title).to eq(original_title)
      end

      it '422を返す' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        subject
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:id' do
    let!(:task1) { Task.create!(title: 'Task 1', status: :todo, position: 1) }
    let!(:task2) { Task.create!(title: 'Task 2', status: :todo, position: 2) }
    let!(:task3) { Task.create!(title: 'Task 3', status: :todo, position: 3) }
    subject { delete api_v1_task_path(task1) }

    context 'タスクが存在する場合' do
      it 'タスクを削除できる' do
        expect { subject }.to change(Task, :count).by(-1)
      end

      it '位置が更新される' do
        subject
        task2.reload
        task3.reload
        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)
      end

      it '200を返す' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'タスクのリストを返す' do
        subject
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['tasks'].size).to eq(2)
      end
    end

    context 'タスクが存在しない場合' do
      it '404を返す' do
        delete api_v1_task_path(100)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/tasks/reorder' do
    let!(:task1) { create(:task, status: :todo, position: 1) }
    let!(:task2) { create(:task, status: :todo, position: 2) }
    let!(:task3) { create(:task, status: :todo, position: 3) }
    subject { post reorder_api_v1_tasks_path, params: params }

    context 'パラメータが有効な場合' do
      let(:params) { { task: { id: task1.id, status: 'done', position: 1 } } }

      it 'ステータスと位置が更新される' do
        subject
        task1.reload
        task2.reload
        task3.reload
        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)
        expect(task1.status).to eq('done')
        expect(task1.position).to eq(1)
      end

      it '200を返す' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'タスクのリストを返す' do
        subject
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['tasks'].size).to eq(3)
      end
    end

    context 'パラメータが無効な場合' do
      let(:params) { { task: { id: task1.id, status: 'invalid_status', position: 2 } } }

      it 'タスクのステータスを更新できない' do
        original_status = task1.status
        subject
        task1.reload
        expect(task1.status).to eq(original_status)
      end

      it '422を返す' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'エラーを返す' do
        subject
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
