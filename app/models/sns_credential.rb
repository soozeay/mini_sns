class SnsCredential < ApplicationRecord
  belongs_to :user, optional: true # レコードを保存する際に、外部キーの値がない場合でも保存ができるオプション
end
