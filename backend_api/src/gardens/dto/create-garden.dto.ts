export class CreateGardenDto {
  name: string;
  spaceType: string;
  latitude: number;  // Captured via Flutter GPS
  longitude: number; // Captured via Flutter GPS
  userId: string;    // The owner of the garden
}