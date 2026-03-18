import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  public auth: admin.auth.Auth;
  public firestore: admin.firestore.Firestore;

  onModuleInit() {
    if (!admin.apps.length) {
      try {
        const privateKey = process.env.FIREBASE_PRIVATE_KEY
          ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
          : undefined;

        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: privateKey,
          }),
        });
        
        this.logger.log('Firebase Admin SDK initialized successfully.');
      } catch (error) {
        this.logger.error('Error initializing Firebase Admin SDK', error.stack);
      }
    }

    this.auth = admin.auth();
    this.firestore = admin.firestore();
  }
}
