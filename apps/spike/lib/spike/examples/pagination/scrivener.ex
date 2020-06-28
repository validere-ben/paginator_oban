defmodule Spike.Examples.Pagination.Scrivener do
  import Ecto.Query

  alias Spike.IAM.Account
  alias Spike.IAM.Role
  alias Spike.IAM.User
  alias Spike.Repo

  # Much simpler since we don't need to worry about generating a cursor
  # composition of the query dynamically still needs to happen - but that needs to happen with
  # Paginator as well

  def q1 do
    query = from(a in Account, order_by: [desc: :name])

    r1 = Repo.paginate(query, page_size: 1, page: 1)
    r2 = Repo.paginate(query, page_size: 1, page: 2)
    r3 = Repo.paginate(query, page_size: 1, page: 3)
    r4 = Repo.paginate(query, page_size: 1, page: 4)

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

    r1 = Repo.paginate(query, page_size: 1, page: 1)
    r2 = Repo.paginate(query, page_size: 1, page: 2)
    r3 = Repo.paginate(query, page_size: 1, page: 3)
    r4 = Repo.paginate(query, page_size: 1, page: 4)

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

    r1 = Repo.paginate(query, page_size: 2, page: 1)
    r2 = Repo.paginate(query, page_size: 2, page: 2)
    r3 = Repo.paginate(query, page_size: 2, page: 3)

    # Exceeding the total_pages count - the last page is returned again (page 3 is returned by this)
    r4 = Repo.paginate(query, page_size: 2, page: 4)

    res = [r1, r2, r3, r4]

    res |> Enum.map(fn r -> Enum.map(r.entries, & &1.role.name) end) |> IO.inspect()

    [query | res]
  end
end
