class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  has_many :sns_credentials

  def self.from_omniauth(auth)
    sns = SnsCredential.where(provider: auth.provider, uid: auth.uid).first_or_create
    # "first_or_create" 保存するレコードがデータベースに存在するか検索を行い、検索した条件のレコードがあればそのレコードのインスタンスを返し、なければ新しくインスタンスを保存する
    # sns認証したことがあればアソシエーションで取得
    # 無ければemailでユーザー検whereメソッドとともに使うことで、whereで検索した条件のレコードがあればそのレコードのインスタンスを返し、なければ新しくインスタンスを作る索して取得orビルド(保存はしない)
    user = User.where(email: auth.info.email).first_or_initialize(
      # "first_or_initialize" whereメソッドとともに使うことで、whereで検索した条件のレコードがあればそのレコードのインスタンスを返し、なければ新しくインスタンスを作る ※新規レコードをデータベースに保存しない
      nickname: auth.info.name,
        email: auth.info.email
    )
    # userが登録済みであるか判断
   if user.persisted?
    sns.user = user
    sns.save
  end
  { user: user, sns: sns } # SNS認証を行ったかの判断をするために、snsに入っているsns_idをビューで扱えるようにするため、コントローラーに渡す
  end
end
