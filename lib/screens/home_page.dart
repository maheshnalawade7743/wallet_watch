import 'package:flutter/material.dart';
import 'package:wallet_watch/screens/update_transaction_form.dart';

import '../hive_database/hive_database.dart';
import 'add_transaction_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<dynamic, dynamic>> transactionDetailsList = [];

  @override
  void initState() {
    retrieveAllTransactionDetails();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Watch"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openPopup(context);
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: transactionDetailsList.length,
        itemBuilder: (context, index) {
          Map<dynamic, dynamic> transaction = transactionDetailsList[index];

          return GestureDetector(
            onDoubleTap: () {
              _openEditPopup(context, transaction,index);
            },
            child: Dismissible(
              
              key:ValueKey(transaction['id']),
                   background: Container(color: Colors.red),
                  // Provide a unique key for each Dismissible
              onDismissed: (direction) async {
                // Delete the transaction from the database
               await HiveDb.deleteData(transaction['id'], key: transaction['id']);
               print(transaction);

               
              },
              child: Container(
                width: double.infinity,
                
                child: Card(  
                  color: transaction["isDebit"] ? Color.fromARGB(255, 224, 140, 131):Color.fromARGB(255, 98, 184, 102),
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${transaction['selectedDate']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Time: ${transaction['selectedTime']}'),
                        SizedBox(height: 8),
                        Text(
                            'Type: ${transaction['isDebit'] ? 'Debit' : 'Credit'}'),
                        SizedBox(height: 8),
                        Text('Amount: ${transaction['amount']}'),
                        SizedBox(height: 8),
                        Text('Description: ${transaction['description']}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> retrieveAllTransactionDetails() async {
    // Retrieve all data from the database
    Map<dynamic, dynamic>? allData = await HiveDb.getAllData();

    if (allData != null && allData.isNotEmpty) {
      setState(() {
        transactionDetailsList =
            List<Map<dynamic, dynamic>>.from(allData.values);
            print(transactionDetailsList);
      });
    }
  }

    void _openPopup(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Transaction Details'),
          content:
              AddTransactionForm(onTransactionAdded: _updateTransactionList),
        );
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      // Handle the result if needed
      print('New transaction added: $result');
    }
  }

  void _updateTransactionList(Map<String, dynamic> newTransaction) {
    setState(() {
      transactionDetailsList.add(newTransaction);
      print(transactionDetailsList);
    });
  }
  
     void _updateEditedTransactionList(Map<String, dynamic> editedTransaction, int index) {
    setState(() {
      transactionDetailsList[index] = editedTransaction;
      print(transactionDetailsList);
    });
  }


 _openEditPopup(BuildContext context, Map<dynamic, dynamic> transaction, int index) async {
  final editedTransaction = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Transaction'),
        content: EditTransactionForm(initialTransaction: transaction, onTransactionEdited: (editedTransaction) {
          _updateEditedTransactionList(editedTransaction, index);
        }),
      );
    },
  );

  if (editedTransaction != null && editedTransaction is Map<String, dynamic>) {
    // Handle the edited transaction data
    print('Transaction edited: $editedTransaction');
    // Update the transaction details in your list or database
    // You might need to implement this logic based on your data structure
  }
}
}
