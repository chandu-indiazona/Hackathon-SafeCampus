import 'package:flutter/material.dart';

class SubmitGrievancePage extends StatefulWidget {
  final String grievanceType;

  const SubmitGrievancePage({Key? key, required this.grievanceType})
      : super(key: key);

  @override
  _SubmitGrievancePageState createState() => _SubmitGrievancePageState();
}

class _SubmitGrievancePageState extends State<SubmitGrievancePage> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _problemController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitGrievance() {
    if (_formKey.currentState!.validate()) {
      // Save the grievance to the profile page (this should be implemented)
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Your grievance has been submitted successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('Submit Grievance - ${widget.grievanceType}'),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/appbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _problemController,
                  decoration: InputDecoration(
                    labelText: 'Problem *',
                    labelStyle: TextStyle(color: Colors.red),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your problem';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (if any)',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
                    ),
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitGrievance,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
