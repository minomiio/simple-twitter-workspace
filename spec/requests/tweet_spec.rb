RSpec.describe 'Tweet', type: :request do
  let(:user) { create(:user, email: FFaker::Internet.email, name: 'no_tweets') }
  let(:user_with_tweets) { create(:user_with_tweets) }

  context '#index' do
    describe 'user not login' do
      it 'will redirect to log in page' do
        get tweets_path
        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(302)
      end
    end

    context 'user log in' do
      before do
        user
        user_with_tweets
        Followship.create(user_id: user.id, following_id: user_with_tweets.id)
        sign_in(user)
        get tweets_path
      end

      it 'can render index' do
        expect(response).to render_template(:index)
      end

      describe 'user behaviour' do
        it 'show current_user as log in user' do
          expect(controller.current_user).to eq(user)
        end

        it 'can show all popular user' do
          expect(assigns(:users).first).to eq(user_with_tweets)
        end
      end

      describe 'tweets behaviour' do
        it 'will show all tweets' do
          expect(response).to have_http_status(200)
        end

        it 'can see all tweets instance' do
          expect(assigns(:tweets)).to eq(Tweet.all)
        end

        it 'have tweet instance' do
          expect(assigns(:tweet)).not_to be nil
        end
      end
    end
  end

  context '#post' do
    before do
      user
      sign_in(user)
      post '/tweets', params: { tweet: { description: 'I am another tweet' } }
    end

    describe 'when successfully save' do
      it 'will redirect to index' do
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(assigns(:tweets))
      end

      it 'will create current users tweet' do
        expect(Tweet.last.user).to eq user
      end
    end

    describe 'when failed' do
      it 'will render index' do
        expect(response).to redirect_to(assigns(:tweets))
      end
    end
  end
end
