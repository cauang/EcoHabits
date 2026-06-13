defmodule Ecohabits.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :bio, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true
    field :points, :integer, default: 0

    timestamps(type: :utc_datetime)
  end


  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end


  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name])
    |> validate_email(opts)
    |> validate_password(opts)
  end

  def profile_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :bio])
    |> validate_required([:name, :email])
    |> validate_profile_email(opts)
    |> validate_length(:bio, max: 160)
  end

  defp validate_profile_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "formato de e-mail inválido"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) and get_change(changeset, :email) do
      changeset
      |> unsafe_validate_unique(:email, Ecohabits.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp validate_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "formato de e-mail inválido"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:email, Ecohabits.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end



  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "as senhas não são iguais")
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)

    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset

      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end


  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end


  def valid_password?(%Ecohabits.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    if String.starts_with?(hashed_password, "$pbkdf2") do
      Pbkdf2.verify_pass(password, hashed_password)
    else

      hashed_password == password
    end
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end
end
