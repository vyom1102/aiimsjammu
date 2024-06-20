// import 'dart:convert';
//
// final doctorsData = [
//   {
//     'name': 'Dr. Krishna Prasad',
//     'speciality': 'Cardiologist',
//     'location': '223 II Floor, Block B',
//     'imageUrl': 'assets/images/DemoDoc.png',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA.',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. (Prof) Sudhir Kumar Rawal',
//     'speciality': 'Pediatrician',
//     'location': 'Los Angeles',
//     'imageUrl': 'assets/images/demodoc2.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA.',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Michael Johnson',
//     'speciality': 'Dermatologist',
//     'location': 'Chicago',
//     'imageUrl': 'assets/images/demodoc2.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Emily Davis',
//     'speciality': 'Ophthalmologist',
//     'location': 'Houston',
//     'imageUrl': 'assets/images/demodoc2.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. William Thompson',
//     'speciality': 'Orthopedic Surgeon',
//     'location': 'Phoenix',
//     'imageUrl': 'assets/images/demodoc2.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Sophia Wilson',
//     'speciality': 'Gynecologist',
//     'location': 'Philadelphia',
//     'imageUrl': 'assets/images/demodoc2.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. David Anderson',
//     'speciality': 'Gastroenterologist',
//     'location': 'San Antonio',
//     'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//
//   },
//   {
//     'name': 'Dr. Olivia Thomas',
//     'speciality': 'Neurologist',
//     'location': 'San Diego',
//   'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//
//   {
//     'name': 'Dr. Daniel Brown',
//     'speciality': 'Cardiologist',
//     'location': 'Dallas',
//   'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//
//   {
//     'name': 'Dr. Emma Martinez',
//     'speciality': 'Psychiatrist',
//     'location': 'San Jose',
//   'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//
//   {
//     'name': 'Dr. John Doe',
//     'speciality': 'Cardiologist',
//     'location': 'New York',
//     'imageUrl': 'assets/images/DemoDoc.png',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Jane Smith',
//     'speciality': 'Pediatrician',
//     'location': 'Los Angeles',
//   'imageUrl': 'assets/images/demodoc4.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Michael Johnson',
//     'speciality': 'Dermatologist',
//     'location': 'Chicago',
//     'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Emily Davis',
//     'speciality': 'Ophthalmologist',
//     'location': 'Houston',
//     'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. William Thompson',
//     'speciality': 'Orthopedic Surgeon',
//     'location': 'Phoenix',
//     'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. Sophia Wilson',
//     'speciality': 'Gynecologist',
//     'location': 'Philadelphia',
//     'imageUrl': 'assets/images/demodoc3.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//   {
//     'name': 'Dr. David Anderson',
//     'speciality': 'Gastroenterologist',
//     'location': 'San Antonio',
//     'imageUrl': 'assets/images/demodoc4.jpeg',
//     'experience': 15,
//     'patients': 1500,
//     'awards': 2,
//     'publications': 4,
//     'about':'Dr. Krishna Prasad a dedicated cardiologist, brings a wealth of experience to Golden Gate Cardiology Center in Golden Gate, CA. View profile',
//     'profile':'https://www.rgcirc.org/doctor/dr-sudhir-kumar-rawal/',
//   },
//
// ];
//
// String getDoctorsData() {
//   return jsonEncode(doctorsData);
// }