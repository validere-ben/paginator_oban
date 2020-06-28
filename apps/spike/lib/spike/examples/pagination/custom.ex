defmodule Spike.Examples.Pagination.Custom do
  import Ecto.Query

  alias Spike.Accounts.Account
  alias Spike.Accounts.Role
  alias Spike.Accounts.User
  alias Spike.Repo

  # Offset / Limit pagination without Scrivener

  def paginate(query, page_size: page_size, page: page) do
    offset = page_size * (page - 1)

    entries = query |> limit(^page_size) |> offset(^offset) |> Repo.all()

    total_entries = total_entries(query)

    total_pages =
      case total_entries do
        0 -> 1
        entries -> (entries / page_size) |> ceil() |> round()
      end

    %{
      entries: entries,
      page_number: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp total_entries(query) do
    query
    |> exclude(:preload)
    |> exclude(:order_by)
    |> subquery()
    |> select(count("*"))
    |> Repo.one()
  end

  def q1 do
    query = from(a in Account, order_by: [desc: :name])

    r1 = paginate(query, page_size: 1, page: 1)
    r2 = paginate(query, page_size: 1, page: 2)
    r3 = paginate(query, page_size: 1, page: 3)
    r4 = paginate(query, page_size: 1, page: 4)

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

    r1 = paginate(query, page_size: 1, page: 1)
    r2 = paginate(query, page_size: 1, page: 2)
    r3 = paginate(query, page_size: 1, page: 3)
    r4 = paginate(query, page_size: 1, page: 4)

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

    r1 = paginate(query, page_size: 2, page: 1)
    r2 = paginate(query, page_size: 2, page: 2)
    r3 = paginate(query, page_size: 2, page: 3)

    # Exceeding the total_pages count - the last page is returned again (page 3 is returned by this)
    r4 = paginate(query, page_size: 2, page: 4)

    res = [r1, r2, r3, r4]

    res |> Enum.map(fn r -> Enum.map(r.entries, & &1.role.name) end) |> IO.inspect()

    [query | res]
  end
end
