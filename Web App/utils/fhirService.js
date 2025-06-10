const FhirKitClient = require('fhir-kit-client');

const client = new FhirKitClient({
    baseUrl: 'https://hapi.fhir.org/baseR4'
});


function mapPatientToFhir(pacient) {
    // UUID temporar pentru pacient
    const patientUUID = `urn:uuid:p-${pacient.CNP}`;

    // Pacient
    const patientResource = {
        resourceType: "Patient",
        name: [{
            family: pacient.Nume,
            given: [pacient.Prenume]
        }],
        gender: pacient.Sex === 'M' ? 'male' : 'female',
        birthDate: new Date(pacient.Data_nasterii).toISOString().split('T')[0],
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

    // Medicația curentă (MedicationRequest)
    const medicationRequests = (pacient.medicationCurrent || []).map((med, index) => ({
        resourceType: "MedicationRequest",
        id: `medreq-${index + 1}`,
        status: "active",
        intent: "order",
        medicationCodeableConcept: {
            text: `${med.denumire_medicament} - ${med.forma_farmaceutica}`
        },
        subject: {
            reference: patientUUID
        },
        dosageInstruction: [{
            text: med.posologie || ''
        }],
        authoredOn: med.data_incepere.toISOString().split('T')[0],
        // Poți adăuga și data ultimei prescrieri aici ca `note` dacă vrei
        note: [`Ultima prescriere: ${med.data_ultima_prescriere.toISOString().split('T')[0]}`]
    }));

    // Istoricul medicației (MedicationStatement)
    const medicationStatements = (pacient.medicationHistory || []).map((med, index) => ({
        resourceType: "MedicationStatement",
        id: `medstat-${index + 1}`,
        status: "completed",
        medicationCodeableConcept: {
            text: `${med.denumire_medicament} - ${med.forma_farmaceutica}`
        },
        subject: {
            reference: patientUUID
        },
        dosage: [{
            text: med.posologie
        }],
        effectivePeriod: {
            start: new Date(med.data_incepere).toISOString().split('T')[0],
            end: new Date(med.data_finalizare).toISOString().split('T')[0]
        },
        note: med.motiv_intrerupere ? [med.motiv_intrerupere] : []
    }));

    // Construim un Bundle cu pacientul și resursele asociate
    const bundle = {
        resourceType: "Bundle",
        type: "transaction",
        entry: [
            {
                fullUrl: patientUUID,
                resource: patientResource,
                request: {
                    method: "POST",
                    url: "Patient"
                }
            },
            ...medicationRequests.map(med => ({
                resource: med,
                request: {
                    method: "POST",
                    url: "MedicationRequest"
                }
            })),
            ...medicationStatements.map(med => ({
                resource: med,
                request: {
                    method: "POST",
                    url: "MedicationStatement"
                }
            }))
        ]
    };

    return bundle;
}



async function sharePatientToFhir(pacient) {
    const fhirBundle = mapPatientToFhir(pacient);

    try {
        const result = await client.transaction({
            body: fhirBundle
        });
        const urls = {};

        result.entry.forEach(e => {
            if (e.response && e.response.location) {
                // ex: "Patient/abc-123", "MedicationRequest/xyz-456"
                const [resourceType, resourceId] = e.response.location.split('/');
                urls[resourceType] = urls[resourceType] || [];
                urls[resourceType].push(`https://hapi.fhir.org/baseR4/${resourceType}/${resourceId}`);
            }
        });

        console.log("URLs resurse FHIR:", urls);

        return result;
    } catch (error) {
        console.error("FHIR transaction error:", error.response?.data || error.message);
        throw error;
    }
}


module.exports = { sharePatientToFhir };
