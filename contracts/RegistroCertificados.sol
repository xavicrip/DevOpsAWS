// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title RegistroCertificados
/// @author Laboratorio DevOps/DevSecOps — UTPL
/// @notice Registra certificados académicos de forma inmutable y verificable en Ethereum.
/// @dev Aplica patrones de seguridad: control de acceso por roles, errores personalizados
///      y eventos de auditoría. Los certificados NO se borran; se revocan.
contract RegistroCertificados {
    // ---------------------------------------------------------------------
    // Tipos
    // ---------------------------------------------------------------------

    struct Certificado {
        string nombreEstudiante;
        string curso;
        address emisor;
        uint256 fechaEmision; // timestamp del bloque
        bool revocado;
        bool existe; // permite distinguir un certificado inexistente de uno vacío
    }

    // ---------------------------------------------------------------------
    // Estado
    // ---------------------------------------------------------------------

    /// @notice Institución propietaria del contrato (máxima autoridad).
    address public immutable propietario;

    /// @notice Emisores autorizados a emitir y revocar certificados.
    mapping(address => bool) public emisorAutorizado;

    /// @notice Certificados indexados por su hash único.
    mapping(bytes32 => Certificado) private certificados;

    /// @dev Contador interno para garantizar hashes únicos aunque coincidan los datos.
    uint256 private nonce;

    // ---------------------------------------------------------------------
    // Eventos (rastro de auditoría)
    // ---------------------------------------------------------------------

    event EmisorAutorizado(address indexed emisor, address indexed por);
    event EmisorRevocado(address indexed emisor, address indexed por);
    event CertificadoEmitido(
        bytes32 indexed hashCertificado,
        string nombreEstudiante,
        string curso,
        address indexed emisor
    );
    event CertificadoRevocado(bytes32 indexed hashCertificado, address indexed emisor);

    // ---------------------------------------------------------------------
    // Errores personalizados (más baratos en gas que require con string)
    // ---------------------------------------------------------------------

    error NoEsPropietario();
    error NoEsEmisorAutorizado();
    error CertificadoNoExiste();
    error CertificadoYaRevocado();
    error DireccionInvalida();
    error DatosVacios();

    // ---------------------------------------------------------------------
    // Modificadores
    // ---------------------------------------------------------------------

    modifier soloPropietario() {
        if (msg.sender != propietario) revert NoEsPropietario();
        _;
    }

    modifier soloEmisor() {
        if (!emisorAutorizado[msg.sender]) revert NoEsEmisorAutorizado();
        _;
    }

    // ---------------------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------------------

    constructor() {
        propietario = msg.sender;
        // El propietario es emisor por defecto para facilitar el arranque.
        emisorAutorizado[msg.sender] = true;
        emit EmisorAutorizado(msg.sender, msg.sender);
    }

    // ---------------------------------------------------------------------
    // Gestión de emisores (solo propietario)
    // ---------------------------------------------------------------------

    /// @notice Autoriza a una dirección a emitir/revocar certificados.
    function autorizarEmisor(address emisor) external soloPropietario {
        if (emisor == address(0)) revert DireccionInvalida();
        emisorAutorizado[emisor] = true;
        emit EmisorAutorizado(emisor, msg.sender);
    }

    /// @notice Retira la autorización de un emisor.
    function revocarEmisor(address emisor) external soloPropietario {
        if (emisor == address(0)) revert DireccionInvalida();
        emisorAutorizado[emisor] = false;
        emit EmisorRevocado(emisor, msg.sender);
    }

    // ---------------------------------------------------------------------
    // Emisión y revocación de certificados (solo emisores)
    // ---------------------------------------------------------------------

    /// @notice Emite un certificado y devuelve su hash único.
    /// @param nombreEstudiante Nombre del estudiante certificado.
    /// @param curso Nombre del curso o programa.
    /// @return hashCertificado Identificador único del certificado.
    function emitirCertificado(string calldata nombreEstudiante, string calldata curso)
        external
        soloEmisor
        returns (bytes32 hashCertificado)
    {
        if (bytes(nombreEstudiante).length == 0 || bytes(curso).length == 0) {
            revert DatosVacios();
        }

        // Usamos abi.encode (no encodePacked) para evitar colisiones de hash entre
        // argumentos dinámicos adyacentes: encodePacked("AB","C") == encodePacked("A","BC").
        hashCertificado = keccak256(
            abi.encode(nombreEstudiante, curso, msg.sender, block.timestamp, nonce)
        );
        unchecked {
            nonce++;
        }

        certificados[hashCertificado] = Certificado({
            nombreEstudiante: nombreEstudiante,
            curso: curso,
            emisor: msg.sender,
            fechaEmision: block.timestamp,
            revocado: false,
            existe: true
        });

        emit CertificadoEmitido(hashCertificado, nombreEstudiante, curso, msg.sender);
    }

    /// @notice Revoca un certificado existente (no lo elimina).
    function revocarCertificado(bytes32 hashCertificado) external soloEmisor {
        Certificado storage cert = certificados[hashCertificado];
        if (!cert.existe) revert CertificadoNoExiste();
        if (cert.revocado) revert CertificadoYaRevocado();
        cert.revocado = true;
        emit CertificadoRevocado(hashCertificado, msg.sender);
    }

    // ---------------------------------------------------------------------
    // Verificación pública (lectura gratuita)
    // ---------------------------------------------------------------------

    /// @notice Verifica un certificado. Cualquiera puede llamarla sin pagar gas.
    /// @return existe Si el certificado fue emitido alguna vez.
    /// @return valido Si existe y NO está revocado.
    /// @return nombreEstudiante Nombre del estudiante.
    /// @return curso Curso certificado.
    /// @return emisor Dirección que lo emitió.
    /// @return fechaEmision Timestamp de emisión.
    function verificarCertificado(bytes32 hashCertificado)
        external
        view
        returns (
            bool existe,
            bool valido,
            string memory nombreEstudiante,
            string memory curso,
            address emisor,
            uint256 fechaEmision
        )
    {
        Certificado storage cert = certificados[hashCertificado];
        existe = cert.existe;
        valido = cert.existe && !cert.revocado;
        nombreEstudiante = cert.nombreEstudiante;
        curso = cert.curso;
        emisor = cert.emisor;
        fechaEmision = cert.fechaEmision;
    }
}
