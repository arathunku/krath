defmodule Krath.RegexCompiler do
  @moduledoc ~S"""
  Creates regex that will escape everything but expressions in `<`, `>`.
  `<`, `>`  are delimieters and they're configurable
  """

  @doc ~S"""
  Compiles regular expression.

  ## Examples
      iex> Krath.RegexCompiler.compile("foo:bar.baz:<[0-9]{2,10}>", "<", ">")
      {:ok, "^foo:bar.baz:([0-9]{2,10})$"}
      iex> Krath.RegexCompiler.compile("foo:bar.baz:<<[0-9]>{2,10}>", "<", ">")
      {:ok, "^foo:bar.baz:(<[0-9]>{2,10})$"}
      iex> Krath.RegexCompiler.compile("foo:bar.baz:<<[0-9]{2,10}>", "<", ">")
      {:error, "unbalanced braces"}
      iex> Krath.RegexCompiler.compile("/foo/bar/url/<[a-z]+>", "<", ">")
      {:ok, "^/foo/bar/url/([a-z]+)$"}
      iex> Krath.RegexCompiler.compile("foo:<bar<.xxx>>baz:<<[0-9]>{2,10}>", "<", ">")
      {:ok, "^foo:(bar<.xxx>)baz:(<[0-9]>{2,10})$"}
  """
  def compile(tpl, delimieter_start \\ "<", delimieter_end \\ ">") do
    tpl = String.split(tpl, "", trim: true)
    with {:ok, idxs} <- delimieters(tpl, delimieter_start, delimieter_end) do
      idxs
      |> Enum.reduce({"", 0}, fn ([a, b], { result , dend } ) ->
        raw = Enum.slice(tpl, dend, a-dend)
        dend = b + 1
        pattern = Enum.slice(tpl, a+1, b-a-1)

        { "#{result}#{raw}(#{pattern})", dend }
      end)
      |> (fn {result, dend} ->
        raw = Enum.slice(tpl, dend, length(tpl))
        {:ok, "^#{result}#{raw}$"}
      end).()
    end
  end

  @doc ~S"""
  Returns positions where first level of delimieters start/end

  ## Examples


      iex> Krath.RegexCompiler.delimieters("/foo/bar/url/<[a-z]+>", "<", ">")
      {:ok, [[13, 20]]}
      iex> Krath.RegexCompiler.delimieters("foo:<bar<.xxx>>baz:<<[0-9]>{2,10}>", "<", ">")
      {:ok, [[4, 14], [19, 33]]}
      iex> Krath.RegexCompiler.delimieters("foo:bar.baz:<<[0-9]{2,10}>", "<", ">")
      {:error, "unbalanced braces"}
  """
  def delimieters(tpl, dstart, dend) when is_list(tpl) do
    tpl
    |> Enum.with_index()
    |> do_delimiete(dstart, dend, [], 0)
    |> case do
      {:ok, idxs} -> {:ok, Enum.chunk_every(idxs, 2)}
      error -> error
    end
  end

  def delimieters(tpl, dstart, dend) do
    tpl = String.split(tpl, "", trim: true)
    delimieters(tpl, dstart, dend)
  end

  defp do_delimiete([], _, _, collected, 0) do
    {:ok, Enum.reverse(collected)}
  end

  defp do_delimiete([], _, _, _, _level) do
    {:error, "unbalanced braces"}
  end

  defp do_delimiete([{l, idx} | tpl], dstart, dend, collected, level) do
    cond do
      l == dstart && level == 0 ->
        do_delimiete(tpl, dstart, dend, [idx | collected], level + 1)

      l == dstart ->
        do_delimiete(tpl, dstart, dend, collected, level + 1)

      l == dend && level == 1 ->
        do_delimiete(tpl, dstart, dend, [idx | collected], level - 1)

      l == dend ->
        do_delimiete(tpl, dstart, dend, collected, level - 1)

      true ->
        do_delimiete(tpl, dstart, dend, collected, level)
    end
  end
end
