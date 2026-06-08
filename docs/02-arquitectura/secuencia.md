# Diagramas de secuencia

## Emitir un certificado (escritura — cuesta gas)

```mermaid
sequenceDiagram
    actor Emisor
    participant FE as DApp Frontend
    participant MM as MetaMask
    participant SC as Contrato
    participant BC as Blockchain

    Emisor->>FE: nombre + curso, clic "Emitir"
    FE->>MM: emitirCertificado(nombre, curso)
    MM-->>Emisor: pide confirmar (muestra gas)
    Emisor->>MM: confirma
    MM->>SC: transacción firmada
    SC->>SC: verifica soloEmisor + datos no vacíos
    SC->>SC: calcula hash, guarda Certificado
    SC->>BC: emite evento CertificadoEmitido
    BC-->>FE: recibo con el hash
    FE-->>Emisor: muestra el hash del certificado
```

Si quien llama no es emisor autorizado, el contrato revierte con `NoEsEmisorAutorizado()` y
no se gasta el cambio de estado.

## Verificar un certificado (lectura — gratis)

```mermaid
sequenceDiagram
    actor Cualquiera
    participant FE as DApp Frontend
    participant RPC as Nodo RPC
    participant SC as Contrato

    Cualquiera->>FE: pega el hash, clic "Verificar"
    FE->>RPC: verificarCertificado(hash) [call view]
    RPC->>SC: lee estado (sin transacción)
    SC-->>RPC: existe, valido, nombre, curso, emisor, fecha
    RPC-->>FE: datos
    FE-->>Cualquiera: VÁLIDO / REVOCADO + detalles
```

La verificación es una llamada `view`: no crea transacción, no cuesta gas y la puede hacer
cualquiera, incluso sin billetera con fondos.

## Revocar un certificado (escritura — cuesta gas)

```mermaid
sequenceDiagram
    actor Emisor
    participant FE as DApp Frontend
    participant MM as MetaMask
    participant SC as Contrato

    Emisor->>FE: pega el hash, clic "Revocar"
    FE->>MM: revocarCertificado(hash)
    MM->>SC: transacción firmada
    SC->>SC: verifica existe y no revocado
    SC->>SC: marca revocado = true
    SC-->>FE: evento CertificadoRevocado
    FE-->>Emisor: "Certificado revocado"
```
