import 'package:Trainity/controller/orderContrller/updatestatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Trainity/Tracking/TrackingScreen.dart';
import 'package:Trainity/controller/oppocontrller/getalloppo.dart';
import 'package:Trainity/model/oppo_model.dart';
import 'package:Trainity/view/company/OpportunityDetailsPage.dart';
import 'package:Trainity/view/company/addnewtraining.dart';
import 'package:Trainity/view/company/updateTraining.dart';

class GetAllCompanyTraining extends StatefulWidget {
  const GetAllCompanyTraining({super.key});

  @override
  State<GetAllCompanyTraining> createState() => _GetAllCompanyTrainingState();
}

class _GetAllCompanyTrainingState extends State<GetAllCompanyTraining> {
  final GetAllOppoController _allOppoController = GetAllOppoController();
  bool search = false;
  bool isloading = false;

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> mydataOppo = [];

  @override
  void initState() {
    super.initState();
    initializeData();
    _allOppoController.getCompanyOpportunitiesStream();
  }

  Future<void> initializeData() async {
    searchController.addListener(onSearchTextChanged);
    _allOppoController.getCompanyOpportunitiesStream();
    setState(() {
      isloading = true;
    });
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchTextChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchTextChanged() {
    setState(() {
      search = searchController.text.isNotEmpty;
      _allOppoController.getSearchStream(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      onSearchTextChanged();
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddNewTraining(),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Color.fromARGB(255, 61, 10, 228),
                  ),
                  child: const Text(
                    'Add New Training',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<OppoModel>>(
                    stream: search
                        ? _allOppoController
                            .getSearchStream(searchController.text)
                        : _allOppoController.getCompanyOpportunitiesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.data?.isEmpty ?? true) {
                        return const Center(
                            child: Text('No opportunities found.'));
                      } else {
                        List<OppoModel> myOppo = snapshot.data!;
                        mydataOppo =
                            myOppo.map((oppo) => oppo.toMap()).toList();
                        return buildListView(myOppo);
                      }
                    },
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildListView(List<OppoModel> myOppo) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              "My Opportunities :",
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myOppo.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OpportunityDetailsPage(
                        opportunity: myOppo[index],
                      ),
                    ));
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Remove Opportunity'),
                          content: Text(
                              'Are you sure you want to remove ${myOppo[index].name} ?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('remove'),
                              onPressed: () {
                                removeOppo(myOppo[index].id);

                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(myOppo[index].name.toString()),
                      subtitle: Text(myOppo[index].description.toString()),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UpdateTraining(
                              data: mydataOppo[index],
                              sDate: myOppo[index].startDate,
                              nStudent: myOppo[index].nOfStudent,
                              oldcond: myOppo[index].conditions,
                              languages: myOppo[index].languages,
                              id: myOppo[index].id,
                            ),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      dense: true,
                      leading: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TrackingScreen(
                                oppoId: myOppo[index].id,
                              ),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.indigo,
                          ),
                          child: const Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  UpdateStatus updateStatus = UpdateStatus();
  Future<void> removeOppo(String last) async {
    try {
      await FirebaseFirestore.instance
          .collection('opportinities')
          .doc(last)
          .delete();

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Training')
              .where('oppo_id', isEqualTo: last)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot
            in querySnapshot.docs) {
          if (documentSnapshot.data()!.containsKey('listOfStudents')) {
            List<dynamic> lists = documentSnapshot.data()!['listOfStudents'];
            await FirebaseFirestore.instance
                .collection('Training')
                .doc(documentSnapshot.id)
                .delete();
            for (int i = 0; i < lists.length; i++) {
              updateStatus.updateStudent(lists[i], '0');
            }
          }
        }
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}
