import 'package:shared_preferences/shared_preferences.dart';

class CalculatorLogic {
  double firstNumber = 0;
  double secondNumber = 0;
  String operator = '';
  double result = 0;
  String displayValue = '0';

  //list to store the history of calculations
  List<String> history = [];
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    history = prefs.getStringList('calc_history') ?? [];
  }

  Future<void> _saveHistoryToDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calc_history', history);
  }

  Future<void> clearHistory() async {
    history.clear();
    await _saveHistoryToDevice();
  }

  Future<void> removeHistoryItem(int index) async {
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await _saveHistoryToDevice();
    }
  }

  bool shouldResetDisplay = false;

  // Function to handle number button presses
  void pressNumber(String number) {
    if (shouldResetDisplay && !displayValue.contains(' ')) {
      displayValue = number;
      shouldResetDisplay = false;
      return;
    }
        if (displayValue == '0') {
      displayValue = number;
    } else {
      displayValue = displayValue + number;
    }
  }

  //clears the calculator state and resets all values to their initial state
  void clear() {
    firstNumber = 0;
    secondNumber = 0;
    operator = '';
    result = 0;
    displayValue = '0';
    shouldResetDisplay = false;
  }

  //delete numbers for the display value
  void deleteNumbers() {
    if (displayValue.length > 1) {
      displayValue = displayValue.substring(0, displayValue.length - 1);
    } else {
      displayValue = '0';
    }
  }

  // slect the operator and store the first number for calculation
  void selectOperator(String op) {
    try {
      firstNumber = double.tryParse(displayValue) ?? 0;
      operator = op;
      displayValue = "$displayValue $op ";
      shouldResetDisplay = false;
    } catch (e) {
      displayValue = '0';
    }
  }

  // Function to calculate the result based on the selected operator and the second number
  void calculateResult() {
    List<String> parts = displayValue.trim().split(' ');

    if (parts.length >= 3) {
      secondNumber = double.tryParse(parts[2]) ?? 0;

      double result = 0;
      switch (operator) {
        case '+':
          result = firstNumber + secondNumber;
          break;
        case '-':
          result = firstNumber - secondNumber;
          break;
        case 'X':
          result = firstNumber * secondNumber;
          break;
        case '/':
          result = secondNumber != 0 ? firstNumber / secondNumber : 0;
          break;
        case '%':
          result = secondNumber != 0 ? firstNumber % secondNumber : 0;
          break;
      }

      String formattedResult;
      if (result % 1 == 0) {
        formattedResult = result.toInt().toString();
      } else {
        formattedResult = result.toString();
      }

      history.add("$displayValue = $formattedResult");
      _saveHistoryToDevice();
      displayValue = formattedResult;
      operator = '';
      shouldResetDisplay = true;
    }
  }
}
