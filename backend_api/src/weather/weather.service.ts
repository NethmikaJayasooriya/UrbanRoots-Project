import { HttpService } from '@nestjs/axios';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class WeatherService {
  constructor(private readonly httpService: HttpService) {}

  async getLiveWeather(latitude: number, longitude: number) {
    const apiKey = process.env.WEATHER_API_KEY;
    
    // units=metric ensures we get Celsius instead of Kelvin
    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${apiKey}&units=metric`;

    try {
      // Make the HTTP GET request to OpenWeather
      const response = await firstValueFrom(this.httpService.get<any>(url));
      
      // We only extract the data UrbanRoots actually cares about
      return {
        temperature: response.data.main.temp,     // e.g., 31.5
        humidity: response.data.main.humidity,    // e.g., 80
        condition: response.data.weather[0].main, // e.g., "Rain", "Clouds", "Clear"
        city: response.data.name,                 // e.g., "Colombo"
      };
    } catch (error) {
      console.error('Weather API Error:', error.message);
      throw new HttpException('Failed to fetch live weather data', HttpStatus.BAD_REQUEST);
    }
  }
}