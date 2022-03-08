class CheckBoxState {
  final String title;
  bool value;
  int index;
  String name;
  CheckBoxState(
      {required this.title,
      this.value = false,
      required this.index,
      required this.name});
}

final checkAllProperties =
    CheckBoxState(title: "All Properties", index: 23, name: "All");
final checkallHeaders =
    CheckBoxState(title: "All Header Details", index: 1, name: "Headers");

final checkalltransactions = CheckBoxState(
    title: "All Transaction Details", index: 2, name: "Transaction");

final checkallfooterDetails =
    CheckBoxState(title: "All Footer Details", index: 3, name: "Footer");

final allCheckedProperties = [];
final allProperties = [
  CheckBoxState(title: "Statement Date", index: 4, name: "valueDate"),
  CheckBoxState(title: "Account  Number", index: 5, name: "id"),
  CheckBoxState(title: "Opening Balance", index: 7, name: "openingBalance"),
  CheckBoxState(title: "Transaction Date", index: 8, name: "closingBalance"),
  // CheckBoxState(title: "Posting  Date", index: 9,name: ),
  CheckBoxState(title: "is Credit", index: 10, name: "credit"),
  CheckBoxState(title: "Currency", index: 11, name: "currency"),
  CheckBoxState(title: "Transaction Code", index: 12, name: "code"),
  CheckBoxState(title: "Is Debit", index: 13, name: "debit"),
  CheckBoxState(title: " Date", index: 14, name: "entryDate"),
];
