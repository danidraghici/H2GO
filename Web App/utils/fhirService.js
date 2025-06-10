const FhirKitClient = require('fhir-kit-client');

const client = new FhirKitClient({
    baseUrl: 'https://hapi.fhir.org/baseR4'
});
function mapPatientToFhir(pacient) {
    return {
        resourceType: "Patient",
        name: [{
            family: pacient.Nume,
            given: [pacient.Prenume]
        }],
        gender: pacient.Sex === 'M' ? 'male' : 'female',
        birthDate: pacient.Data_nasterii.toISOString().split('T')[0], // 'YYYY-MM-DD'
        address: [{
            text: pacient.Adresa
        }],
        telecom: [
            { system: "phone", value: pacient.Telefon },
            { system: "email", value: pacient.Email }
        ],
        identifier: [{
            system: "urn:cnp",
            value: pacient.CNP
        }]
    };
}


async function sharePatientToFhir(pacient) {
    const fhirPatient = mapPatientToFhir(pacient);
    const result = await client.create({
        resourceType: 'Patient',
        body: fhirPatient
    });
    return result;
}

module.exports = { sharePatientToFhir };
