defmodule ClientWeb.Jsons.ChangesetJson do
  import ClientWeb.Jsons.ErrorHelpers

  @fields_translation [
    {:name_store, "name_store"},
    {:description, "description"},
    {:adress, "adress"},
    {:neighborhood, "neighborhood"},
    {:number, "number"},
    {:cep, "cep"},
    {:cnpj, "cnpj"},
    {:phone, "phone"}
  ]

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_fields(erros) do
    @fields_translation
    |> Enum.reduce(erros, fn {field, translated_field}, erros ->
      field_value = Map.get(erros, field)

      if field_value != nil do
        translated_erros =
          erros
          |> Map.put(translated_field, field_value)
          |> Map.delete(field)

        translated_erros
      else
        erros
      end
    end)
  end

  def error(%{changeset: changeset}) do
    erros =
      changeset
      |> translate_errors()
      |> translate_fields()

    %{errors: erros}
  end
end
