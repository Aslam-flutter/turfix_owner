import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turfix_owner/model/auth_model.dart';
import 'package:turfix_owner/model/turf_model.dart';

class FirestoreServices {
  Future<void> addOwnerDetails(AuthModel model) async {
    await FirebaseFirestore.instance
        .collection('owners')
        .doc(model.uid)
        .set(model.toJson());
  }

  Future<void> addTurf(TurfModel turfModel) async {
    await FirebaseFirestore.instance
        .collection('turfs')
        .add(turfModel.toJson());
  }

  Future<void> deleteTurf(String uid) async {
    await FirebaseFirestore.instance.collection('turfs').doc(uid).delete();
  }
}
