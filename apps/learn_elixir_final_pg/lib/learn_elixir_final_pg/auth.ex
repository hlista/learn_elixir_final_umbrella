defmodule LearnElixirFinalPg.Auth do
  alias LearnElixirFinalPg.Auth.User
  alias EctoShorts.Actions

  def all_users(params, opts \\ []) do
    Actions.all(User, params, opts)
  end

  def find_user(params, opts \\ []) do
    Actions.find(User, params, opts)
  end

  def create_user(params, opts \\ []) do
    Actions.create(User, params, opts)
  end

  def delete_user(id, opts \\ []) do
    Actions.delete(User, id, opts)
  end

  def find_and_update_user(find_params, update_params, opts \\ []) do
    Actions.find_and_update(User, find_params, update_params, opts)
  end

  def find_and_upsert_user(find_params, update_params, opts \\ []) do
    Actions.find_and_upsert(User, find_params, update_params, opts)
  end

  def find_or_create_user(params, opts \\ []) do
    Actions.find_or_create(User, params, opts)
  end

  def find_or_create_many_user(params_list, opts \\ []) do
    Actions.find_or_create_many(User, params_list, opts)
  end

  def update_user(id, update_params, opts \\ []) do
    Actions.update(User, id, update_params, opts)
  end
end
