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

  # Cria um changeset para registro ou alteração de e-mail
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end

  # Changeset principal para criar conta com nome, e-mail e senha
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

  defp validate_email_changed(changeset) do
    if get_field(changeset, :email) && get_change(changeset, :email) == nil do
      add_error(changeset, :email, "não sofreu alteração")
    else
      changeset
    end
  end

  # Changeset para trocar a senha
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
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  # Confirma a conta gerando a data atual
  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end

  # Checa se a senha é válida usando Pbkdf2 ou texto puro (legado)
  def valid_password?(%Ecohabits.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    if String.starts_with?(hashed_password, "$pbkdf2") do
      Pbkdf2.verify_pass(password, hashed_password)
    else
      # Fallback para o banco legado que tinha senha em plain-text
      hashed_password == password
    end
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end
end
