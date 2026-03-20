import { Global, Module, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { FirebaseService } from './firebase.service';

@Global()
@Module({
  providers: [
    {
      provide: 'FIREBASE_APP',
      useFactory: (configService: ConfigService) => {
        const logger = new Logger('FirebaseModule');

        // Prevent re-initialising on hot-reload
        if (admin.apps.length > 0) {
          logger.log('Firebase Admin already initialised — reusing existing app.');
          return admin.app();
        }

        const projectId = configService.get<string>('FIREBASE_PROJECT_ID');
        const clientEmail = configService.get<string>('FIREBASE_CLIENT_EMAIL');
        // Env files store \n as literal characters; replace them with real newlines
        const privateKey = configService
          .get<string>('FIREBASE_PRIVATE_KEY')
          ?.replace(/\\n/g, '\n');

        if (!projectId || !clientEmail || !privateKey) {
          throw new Error(
            'Missing Firebase credentials in environment variables. ' +
              'Ensure FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY are set.',
          );
        }

        const app = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });

        logger.log(`Firebase Admin initialised for project: ${projectId}`);
        return app;
      },
      inject: [ConfigService],
    },
    FirebaseService,
  ],
  exports: ['FIREBASE_APP', FirebaseService],
})
export class FirebaseModule {}
