import 'package:cloud_firestore/cloud_firestore.dart';

class StringStatusManager {
  static final StringStatusManager _instance = StringStatusManager._internal();
  factory StringStatusManager() => _instance;
  StringStatusManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'stringAvailability';

  final Map<String, int> _stringCosts = {
    "BG65 Ti\nWhite": 22,
    "BG65 Ti\nPink": 22,
    "BG65 Ti\nYellow": 22,
    "BG80\nWhite": 24,
    "BG80\nYellow": 24,
    "Exbolt 63\nYellow": 25,
    "Aerobite\nWhite/Red": 26,
  };

  Future<bool> isInStock(String stringName) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(_getDocumentId(stringName)).get();
          if (doc.exists) {
            return doc.data()?['availability'] ?? true;
          } else {
            await _createStringDocument(stringName);
            return true;
          }
    } catch (e) {
      print('Error checking stock status: $e');
      return true; // Default to in stock if error occurs
    }
  }

  Future<void> updateStatus(String stringName, bool isInStock) async {
    try {
      final docId = _getDocumentId(stringName);
      print('Updating document: $docId with availability: $isInStock');

      await _firestore.collection(_collectionName).doc(docId).set({
        'availability': isInStock,
        'cost': _stringCosts[stringName] ?? 20,
      }, SetOptions(merge: true));

      print('Successfully updated document: $docId');
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> updateCost(String stringName, double newCost) async {
    try {
      final docId = _getDocumentId(stringName);
      print('Updating document: $docId with cost: $newCost');

      await _firestore.collection(_collectionName).doc(docId).set({
        'availability': true,
        'cost': newCost,
      }, SetOptions(merge: true));

      print('Successfully updated cost for document: $docId');
    } catch (e) {
      print('Error updating cost: $e');
    }
  }

  Future<double> getCost(String stringName) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(_getDocumentId(stringName)).get();
      if (doc.exists) {
        final cost = (doc.data()?['cost'] as num?)?.toDouble() ?? 20.0;
        return cost;
      } else {
        await _createStringDocument(stringName);
        final cost = (_stringCosts[stringName] ?? 20).toDouble();
        return cost;
      }
    } catch (e) {
      print('Error getting cost: $e');
      final cost = (_stringCosts[stringName] ?? 20).toDouble();
      return cost;
    }
  }

  Future<void> _createStringDocument(String stringName) async {
    try {
      await _firestore.collection(_collectionName).doc(_getDocumentId(stringName)).set({
        'availability': true,
        'cost': _stringCosts[stringName] ?? 20,
      });
    } catch (e) {
      print('Error creating document: $e');
    }
  }

  Future<void> initializeStringAvailability() async {
    try {
      print('=== INITIALIZING STRING AVAILABILITY ===');
      print('Collection name: $_collectionName');
      
      for (String stringName in _stringCosts.keys) {
        final docId = _getDocumentId(stringName);
        print('Processing: $stringName -> Document ID: $docId');
        
        final docData = {
          'availability': true,
          'cost': _stringCosts[stringName] ?? 20,
        };
        print('Document data: $docData');
        
        await _firestore.collection(_collectionName).doc(docId).set(docData, SetOptions(merge: true));
        print('✅ Successfully created/updated document: $docId');
      }
      
      print('=== INITIALIZATION COMPLETE ===');
      
      final snapshot = await _firestore.collection(_collectionName).get();
      print('Verification: Found ${snapshot.docs.length} documents in collection');
      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}, Data: ${doc.data()}');
      }
      
    } catch (e) {
      print('❌ Error initializing string availability: $e');
      print('Error details: ${e.toString()}');
    }
  }

  String _getDocumentId(String stringName) {
    return stringName
        .replaceAll('\n', '_')
        .replaceAll(' ', '_')
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll('#', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_')
        .toLowerCase();
  }

  Future<Map<String, bool>> getAllStatus() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      Map<String, bool> statusMap = {};
      
      for (var doc in snapshot.docs) {
        final stringName = _getStringNameFromDocumentId(doc.id);
        statusMap[stringName] = doc.data()['availability'] ?? true;
      }
      
      return statusMap;
    } catch (e) {
      print('Error getting all status: $e');
      return {};
    }
  }

  Future<void> testFirestoreConnection() async {
    try {
      print('=== TESTING FIRESTORE CONNECTION ===');
      
      final testDoc = await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });
      print('✅ Firestore connection successful');
      
      await _firestore.collection('test').doc('connection').delete();
      print('✅ Test document cleaned up');
      
    } catch (e) {
      print('❌ Firestore connection failed: $e');
    }
  }

  String _getStringNameFromDocumentId(String docId) {
    final mapping = {
      'bg65_ti_white': 'BG65 Ti\nWhite',
      'bg65_ti_pink': 'BG65 Ti\nPink',
      'bg65_ti_yellow': 'BG65 Ti\nYellow',
      'bg80_white': 'BG80\nWhite',
      'bg80_yellow': 'BG80\nYellow',
      'exbolt_63_yellow': 'Exbolt 63\nYellow',
      'aerobite_white_red': 'Aerobite\nWhite/Red',
    };
    return mapping[docId] ?? docId.replaceAll('_', '\n');
  }
}
