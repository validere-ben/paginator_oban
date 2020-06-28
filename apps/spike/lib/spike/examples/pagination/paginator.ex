defmodule Spike.Examples.Pagination.Paginator do
  import Ecto.Query

  alias Spike.IAM.Account
  alias Spike.IAM.Role
  alias Spike.IAM.User
  alias Spike.Repo

  # Paginator master has added support for sorting by joined/assoc columns (made possible by
  # named bindings introduced in ecto 3.0)

  # The current version released to hex does not have this functionality, to use this functionality
  # Add the git source to deps
  # {:paginator, git: "git@github.com:duffelhq/paginator.git"}

  # Scrivener offers traditional offset based pagination which is much simpler and only requires
  # specification of page number and page size in requests (along with sorting/filtering options)
  # Sorting can be handled entirely within the ecto queryable with Scrivener.

  # Page Num, Page Size, Total Pages, & Total Entries would be additional useful/required page
  # metadata properties to include in responses with offset pagination

  # keyset / cursor pagination as with Paginator would work with before/after cursors in the
  # responses. The initial page request would simply specify a limit (i.e. page size)
  # A total record count may also be included but not necessary
  # These cursors would be suplied when requesting additional pages (either forward or backwards)

  # Most basic example
  def q1 do
    query = from(a in Account, order_by: [desc: :name])

    cursor_fields = [:name]

    r1 = Repo.paginator(query, cursor_fields: cursor_fields, sort_direction: :desc, limit: 1)

    r2 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r1.metadata.after
      )

    r3 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r2.metadata.after
      )

    r4 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r3.metadata.after
      )

    res = [r1, r2, r3, r4]

    res |> Enum.map(fn r -> Enum.map(r.entries, & &1.name) end) |> IO.inspect()

    [query | res]
  end

  # Sorted by joined columns / filtering ex. 1
  def q2 do
    query =
      from(r in Role,
        as: :roles,
        join: a in assoc(r, :account),
        as: :accounts,
        preload: [:account],
        where: r.name == "Admin",
        order_by: [desc: a.name]
      )

    cursor_fields = [{:accounts, :name}]

    r1 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        fetch_cursor_value_fun: fn
          role, {:accounts, :name} -> role.account.name
          role, field -> Paginator.default_fetch_cursor_value(role, field)
        end
      )

    r2 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r1.metadata.after,
        fetch_cursor_value_fun: fn
          role, {:accounts, :name} -> role.account.name
          role, field -> Paginator.default_fetch_cursor_value(role, field)
        end
      )

    r3 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r2.metadata.after,
        fetch_cursor_value_fun: fn
          role, {:accounts, :name} -> role.account.name
          role, field -> Paginator.default_fetch_cursor_value(role, field)
        end
      )

    r4 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r3.metadata.after,
        fetch_cursor_value_fun: fn
          role, {:accounts, :name} -> role.account.name
          role, field -> Paginator.default_fetch_cursor_value(role, field)
        end
      )

    res = [r1, r2, r3, r4]

    res |> Enum.map(fn r -> Enum.map(r.entries, & &1.name) end) |> IO.inspect()

    [query | res]
  end

  # Sorted by joined columns / filtering ex. 2
  def q3 do
    query =
      from(u in User,
        as: :users,
        join: r in assoc(u, :role),
        as: :roles,
        join: a in assoc(r, :account),
        as: :accounts,
        where: a.name == "Account - 1",
        preload: [role: :account],
        order_by: [desc: a.name, desc: r.name]
      )

    cursor_fields = [{:accounts, :name}, {:roles, :name}]

    r1 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        fetch_cursor_value_fun: fn
          user, {:accounts, :name} -> user.role.account.name
          user, {:roles, :name} -> user.role.name
          user, field -> Paginator.default_fetch_cursor_value(user, field)
        end
      )

    r2 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r1.metadata.after,
        fetch_cursor_value_fun: fn
          user, {:accounts, :name} -> user.role.account.name
          user, {:roles, :name} -> user.role.name
          user, field -> Paginator.default_fetch_cursor_value(user, field)
        end
      )

    r3 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r2.metadata.after,
        fetch_cursor_value_fun: fn
          user, {:accounts, :name} -> user.role.account.name
          user, {:roles, :name} -> user.role.name
          user, field -> Paginator.default_fetch_cursor_value(user, field)
        end
      )

    r4 =
      Repo.paginator(query,
        cursor_fields: cursor_fields,
        sort_direction: :desc,
        limit: 1,
        after: r3.metadata.after,
        fetch_cursor_value_fun: fn
          user, {:accounts, :name} -> user.role.account.name
          user, {:roles, :name} -> user.role.name
          user, field -> Paginator.default_fetch_cursor_value(user, field)
        end
      )

    res = [r1, r2, r3, r4]

    res |> Enum.map(fn r -> Enum.map(r.entries, & &1.role.name) end) |> IO.inspect()

    [query | res]
  end

  # Dynamic cursor field values i.e. jsonb key, has_many/many_to_many conditionals
  def q4 do
    query =
      from(u in User,
        as: :users,
        join: r in assoc(u, :role),
        as: :roles,
        join: a in assoc(r, :account),
        as: :accounts,
        where: a.name == "Account - 1",
        preload: [role: :account],
        order_by: [desc: a.name, desc: r.name]
      )

    cursor_fields = [{:accounts, :name, "dynamic"}, {:roles, :name}]

    Repo.paginator(query,
      cursor_fields: cursor_fields,
      sort_direction: :desc,
      limit: 1,
      fetch_cursor_value_fun: fn
        user, {:accounts, :name, dynamic} ->
          IO.inspect(dynamic)
          user.role.account.name

        user, {:roles, :name} ->
          user.role.name

        user, field ->
          Paginator.default_fetch_cursor_value(user, field)
      end
    )
  end

  # cursor_val(record, cursor_field)
  # cursor_val(record, {named_binding, key})
  # cursor_val(record, {named_binding, key, val})
  def cursor_val(sample, {:samples, field}) do
    # simple sorting by top level record column
    Map.get(sample, field)
  end

  def cursor_val(sample, {:samples, :metadata, meta_key}) do
    # jsonb field sorting with dynamic key value
    sample.metadata[meta_key]
  end

  def cursor_val(sample, {:stream, :name}) do
    # simple sorting by assoc column
    sample.stream.name
  end

  def cursor_val(sample, {:tests, :type, type}) do
    # dynamic conditional sorting for has_many/many_to_many assoc
    case Enum.find(sample.tests, &(&1.type == type)) do
      nil -> nil
      test -> test.type
    end
  end

  def cursor_val(sample, {:measurements, :value, type}) do
    # dynamic conditional sorting for nested has_many/many_to_many assoc
    sample.test
    |> Enum.flat_map(& &1.measurements)
    |> Enum.find(&(&1.type == type))
    |> case do
      nil -> nil
      measurement -> measurement.value
    end
  end

  def cursor_val(sample, _term) do
    # Any column, joined assocs, etc should be able to be handled by the
    # fetch_cursor_value_fun hook
    sample
  end
end
