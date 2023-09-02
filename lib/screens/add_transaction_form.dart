import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../hive_database/hive_database.dart';

class AddTransactionForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onTransactionAdded;

  const AddTransactionForm({Key? key, required this.onTransactionAdded})
      : super(key: key);

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController selectDateController = TextEditingController();
  TextEditingController selectTimeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final initialDate = DateTime.now();
  final initialTime = TimeOfDay.now();
  late DateTime date;

  bool isDebit = true; // To track whether it's debit or create

  String transactionDetailsId = " ";

  String compareTime="";
  // Define a variable to store the seconds
int selectedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the current date
    selectDateController.text = _formatDate(DateTime.now());
    selectTimeController.text = _formatTime(TimeOfDay.now());
    
    // Get the current seconds and set compareTime
  DateTime now = DateTime.now();
  int currentSeconds = now.second;
  compareTime = _compareFormatTime(TimeOfDay.now(), currentSeconds);
  print('88888888888888${compareTime}');
    
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// select date
            TextFormField(
              controller: selectDateController,
              readOnly: true, // This prevents manual input in the text field
              onTap: addDate,
              decoration: InputDecoration(
                labelText: 'Select Date',
              ),
            ),
            // select time
            TextFormField(
              controller: selectTimeController,
              readOnly: true, // This prevents manual input in the text field
              onTap: addTime,
              decoration: InputDecoration(
                labelText: 'Select Time',
              ),
            ),

            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isDebit,
                  onChanged: (value) => setTransactionMode(value!),
                ),
                Text('Debit'),
                SizedBox(width: 20),
                Radio(
                  value: false,
                  groupValue: isDebit,
                  onChanged: (value) => setTransactionMode(value!),
                ),
                Text('Create'),
              ],
            ),

            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount cannot be empty';
                }
                return null;
              },
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addEnterTransactionDetails,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future addEnterTransactionDetails() async {
    if (_formKey.currentState!.validate()) {
      // Collect all the data and store it in a map

      final uniqueKey = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        transactionDetailsId = uniqueKey;
      });
      
      print('-----${transactionDetailsId}');
      Map<String, dynamic> enterTransactionDetails = {
        'id': transactionDetailsId,
        'selectedDate': selectDateController.text,
        'selectedTime': selectTimeController.text,
        'isDebit': isDebit,
        'amount': amountController.text.toString(),
        'description': descriptionController.text,
        'compareTime': compareTime.toString(),
      };

      await HiveDb.addData(key: transactionDetailsId, value: enterTransactionDetails);

      // Call the callback function to notify the parent about the new transaction
      widget.onTransactionAdded(enterTransactionDetails);

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

  String _formatTime(TimeOfDay time) {
    final formattedTime = DateFormat('h:mm a').format(
      DateTime(2023, 1, 1, time.hour, time.minute),
    );
    return formattedTime;
  }

String _compareFormatTime(TimeOfDay time, int seconds) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

 


// Function for adding a date using a date picker
addDate() async {
  DateTime? date = await showDatePicker(
    context: context,
    firstDate: DateTime.now().subtract(Duration(days: 365 * 2)), // 2 years before today
    lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    initialDate: DateTime.now(),
  );

  if (date != null) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date); // Format the date
    setState(() {
      selectDateController.text = formattedDate;
    });
  } else {
    // Handle the situation where the user didn't select a date
    // For example, you can display a message or take other actions
    print('No date selected');
  }
}
// Function for adding a time using a time picker
addTime() async {
  TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time != null) {
    // Get the current seconds
    DateTime now = DateTime.now();
    selectedSeconds = now.second;

    String selectedTime = _formatTime(time);
    String selectedCompareTime = _compareFormatTime(time, selectedSeconds);

    setState(() {
      selectTimeController.text = selectedTime;
      compareTime = selectedCompareTime;
    });
  } else {
    // Handle the situation where the user didn't select a time
    // For example, you can display a message or take other actions
    print('No time selected');
  }
}

  // Function to set the transaction mode
  setTransactionMode(bool isDebitMode) {
    setState(() {
      isDebit = isDebitMode;
    });
  }
}
