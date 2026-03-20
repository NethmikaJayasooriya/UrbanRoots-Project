import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  // Access Firestore
  get firestore(): admin.firestore.Firestore {
    return admin.firestore();
  }

  // Access Firebase Auth (Used by UserService for profile logic)
  get auth(): admin.auth.Auth {
    return admin.auth();
  }

  // Access Firebase Storage
  get storage(): admin.storage.Storage {
    return admin.storage();
  }
}