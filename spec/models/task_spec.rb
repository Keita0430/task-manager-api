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

  describe '#reorder_tasks' do
    let!(:task1) { Task.create!(title: 'Task 1', status: :todo, position: 1) }
    let!(:task2) { Task.create!(title: 'Task 2', status: :todo, position: 2) }
    let!(:task3) { Task.create!(title: 'Task 3', status: :todo, position: 3) }

    context '同じステータス内で順番を入れ替える場合' do
      context '位置を大きくした場合' do
        it '対象のタスクが指定の位置に移動し、他のタスクが正しく調整される' do
          Task.reorder_tasks(task1, 'todo', 3)

          task1.reload
          task2.reload
          task3.reload

          expect(task2.position).to eq(1)
          expect(task3.position).to eq(2)
          expect(task1.position).to eq(3)
        end
      end

      context '位置を小さくした場合' do
        it '対象のタスクが指定の位置に移動し、他のタスクが正しく調整される' do
          Task.reorder_tasks(task3, 'todo', 1)

          task1.reload
          task2.reload
          task3.reload

          expect(task3.position).to eq(1)
          expect(task3.status).to eq('todo')
          expect(task1.position).to eq(2)
          expect(task2.position).to eq(3)
        end
      end
    end

    context '異なるステータスに移動する場合' do
      let!(:task4) { Task.create!(title: 'Task 4', status: :in_progress, position: 1) }
      let!(:task5) { Task.create!(title: 'Task 5', status: :in_progress, position: 2) }

      it '対象のタスクが移動先ステータスの指定位置に移動し、他のタスクが正しく調整される' do
        Task.reorder_tasks(task1, 'in_progress', 2)

        task1.reload
        task2.reload
        task3.reload
        task4.reload
        task5.reload

        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)

        expect(task4.position).to eq(1)
        expect(task1.position).to eq(2)
        expect(task1.status).to eq('in_progress')
        expect(task5.position).to eq(3)
      end
    end
  end

  describe '#reorder_tasks_after_deletion' do
    let!(:task1) { Task.create!(title: 'Task 1', status: :todo, position: 1) }
    let!(:task2) { Task.create!(title: 'Task 2', status: :todo, position: 2) }
    let!(:task3) { Task.create!(title: 'Task 3', status: :todo, position: 3) }

    context 'タスクを削除した場合　' do
      it '同じステータスを持つタスクのポジションを再計算する' do
        Task.reorder_tasks_after_deletion('todo', 1)

        task2.reload
        task3.reload

        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)
      end
    end
  end
end
