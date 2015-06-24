# DNS
## Description

The Domain Name System (DNS) is a hierarchical distributed naming system for computers, services, or any resource connected to the Internet or a private network. It associates various information with domain names assigned to each of the participating entities. Most prominently, it translates domain names, which can be easily memorized by humans, to the numerical IP addresses needed for the purpose of computer services and devices worldwide. The Domain Name System is an essential component of the functionality of most Internet services because it is the Internet's primary directory service.

## Structure
```
0                             1  1  1  1  1  1
0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|                      ID                       |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|                    QDCOUNT                    |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|                    ANCOUNT                    |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|                    NSCOUNT                    |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
|                    ARCOUNT                    |
+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
```

<table>
    <tr>
      <th style="width:10%">Field Name</th>
      <th style="width:10%">Size (bytes)</th>
      <th style="width:100%">Description</th>
    </tr>
    <tr>
      <td>ID</td>
      <td>2</td>
      <td>
        <b>Identifier:</b> This identifier, generated in the query message, is copied the  corresponding reply and can be used by the requester to match up replies to outstanding queries.
      </td>
    </tr>
    <tr>
      <td>QR</td>
      <td>1 bit</td>
      <td>
        <b>Query/Response Flag:</b> Specifies whether this message is a query (0), or a response (1).
      </td>
    </tr>
    <tr>
      <td>Opcode</td>
      <td>4 bits</td>
      <td>
        <b>Operation Code:</b> Specifies the type of query the message is carrying :
        <ul>
          <li>0 a standard query (QUERY)</li>
          <li>1 an inverse query (IQUERY) <b>obsolete</b></li>
          <li>2 a server status request (STATUS)</li>
          <li>3 reserved, not used. (reserved)</li>
          <li>4 a special message used by primary servers to tell secondary servers that data for a zone has changed and prompt them to request a zone transfer. (NOTIFY)</li>
          <li>5 a special message to implement "dynamic DNS". (UPDATE)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>AA</td>
      <td>1 bit</td>
      <td>
        <b>Authoritative Answer Flag:</b> Indicates that the server that created the response is authoritative (1), or not (0), for the zone in which the domain name specified in the Question section is located.
      </td>
    </tr>
    <tr>
      <td>TC</td>
      <td>1 bit</td>
      <td>
        <b>Truncation Flag:</b> When set to 1, indicates that the message was truncated due to its length being longer than the maximum permitted for the type of transport mechanism used.
      </td>
    </tr>
    <tr>
      <td>RD</td>
      <td>1 bit</td>
      <td>
         <b>Recursion Desired:</b> When set in a query, requests that the server receiving the query attempt to answer the query recursively, if the server supports recursive resolution. The value of this bit is not changed in the response.
      </td>
    </tr>
    <tr>
      <td>RA</td>
      <td>1 bit</td>
      <td>
        <b>Recursion Available:</b> Indicates whether the server creating the response supports recursive queries (1), or not (0).
      </td>
    </tr>
    <tr>
      <td>Z</td>
      <td>3 bits</td>
      <td>
        <b>Zero:</b> Three reserved bits set to zero.
      </td>
    </tr>
    <tr>
      <td>RCode</td>
      <td>4 bits</td>
      <td>
        <b>Response Code:</b> Indicates if the query was answered successfully, or if some error occurred :
        <ul>
          <li>0 No Error (NO_ERROR)</li>
          <li>1 Format Error (FORMAT_ERROR)</li>
          <li>2 Server Failure (SERVER_FAILURE)</li>
          <li>3 Name Error (NAME_ERROR)</li>
          <li>4 Not Implemented (NOT_IMPLEMENTED)</li>
          <li>5 Refused (REFUSED)</li>
          <li>6 YX Domain (YX_DOMAIN)</li>
          <li>7 XY RR Set (XY_RR_SET)</li>
          <li>8 NX RR Set (NX_RR_SET)</li>
          <li>9 Not Auth (NOT_AUTH)</li>
          <li>10 Not Zone (NOT_ZONE)</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>QDCount</td>
      <td>2</td>
      <td>
        <b>Question Count:</b> Number of questions in the <i>Question</i> section of the message
      </td>
    </tr>
    <tr>
      <td>ANCount</td>
      <td>2</td>
      <td>
        <b>Answer Record Count:</b> Number of resource records in the <i>Answer</i> section of the message.
      </td>
    </tr>
    <tr>
      <td>NSCount</td>
      <td>2</td>
      <td>
        <b>Authority Record Count:</b> Number of resource records in the <i>Authority</i> section of the message.
      </td>
    </tr>
    <tr>
      <td>ARCount</td>
      <td>2</td>
      <td>
        <b>Additional Record Count:</b> Number of resource records in the <i>Additional</i> section of the message.
      </td>
    </tr>
</table>

## References

- Domain Names - Implementation and specification [RFC 1035](https://www.ietf.org/rfc/rfc1035.txt)
- A Mechanism for Prompt Notification of Zone Changes [RFC 1996](https://www.ietf.org/rfc/rfc1996.txt)
- Dynamic Updates in the Domain Name System [RFC 2136](https://www.ietf.org/rfc/rfc2136.txt)
