System of toll roads problem


1.Background

The toll road system is interoperable network, which is being used in automotive. Specifically, in this concept we have a customer (vehicle with one driver, unique license plate) and he wants to use one of toll facilities to travel some distance in a shorter period of time. The reason why people has 

2.Problem

Although first toll road transponder was introduced in the late. Due to terrain problem(toll roads can be in roads, but also in tunnels, bridges etc.) these transponders needs to have some requirements and directives. Besides that, toll road operators must handle with costs in a different way. Finally, to have interoperability in this network and perform operations in this system between customers and toll road agencies, between toll roads operators and agencies that are responsible for this solution, set of rules is required to set consensus between these agencies. For drivers there is a problem with continously changing toll charges due to unstable regulation. In cutting it short, we need a good system to perform toll collection.

So far there are two methods of performing toll collections

* Toll booth - At the toll booth transaction between customer and toll agency is started. Driver gives toll operator money. After an agreement between sides (cost, duration etc.) transaction goes successfully. Although transaction is going directly between toll agency and customer, it has one problem - transcation duration is very high.

* Automated toll collection - works like a transponder. It guarantees that transactions between sides would operate vast faster than in tradidional, toll booth way.  In automated toll collection, there is no need to perform hand-to-hand transaction, therefore it is faster.

3.Blockchain system

Blockchain-based peer-to-peer system would guarantee interoperability in electronic toll collection and make possible for payments to be sent directly from customer to toll road operator without any third-party mediator. This way of implementing toll road system would guarantee that a transaction between customer and toll operator would be realized in a distributed network, from any place on earth. This system provides information about customer(register contains information about customer like driver address, license plate, transponder) and transactions performed between sides would be stored in toll transaction ledger. In order to perform transaction quickly, drivers use a digital wallet to store money and pay for an usage of toll road operator. Transaction would be performed directly from customer wallet, whio could perform in transaction by accepting it and perform cryptographically signment. 

4.Architecture

In case of toll road system, it's mandatory to take a look at few conspects. Firstly, participators - in case of this system, toll road operators would be attached to the network and be acting like nodes. Drivers are registered as a participators and their digital wallet would be attached to the network. In order to participate in network, customers are obligated to go through a certification process in order to get private unique keys. It's mandatory if this system have to be secured. Next, we have to implement suppliers to the system in order to validate information about vehicles, suppliers etc. For example, if we want to verify license plates and registered owned information, we need to get an information it from some department or government organisation that is responsible for it in a specified country. Customers would store asset information like license plates, transponder id etc. In the terms of transactions, they will be stored as nowadays. An information about customer would be either by reading information from transponder or taking picture from license plate. There would be no payment from driver transponder account but directly from digital wallet. Transaction would be approved by clicking some button like accept in mobile app, but there are surely more ways of accepting that kind of transaction. Toll road operators stores and has an access to wallets and valuable data. 

5. Pros & cons

Blockchain-based peer-to-peer system has various advantages over traditional system. Let's take a deeper look. If driver had a possibility to store credit to his account in smart contract then payment system would work like credit card, except for a fact that transactions could make happen without any card. While potential driver would pass through the roll, payments for his account would be auto-debited. Furthermore, there is no way that money deposed inside smart contract could be stolen. With good implementation of smart contract, any potential driver could easily check any toll fee at any time just with executing proper smart contract function. There is a possibility to create integrate blockchain with GPS system, what could be useful for drivers to check distances between tolls and check fees for given toll. Finally, smart contract could let driver to book his trip early, what could lead to less payments 
    On the other side, that system has few cons. Each potential driver needs to register his vehicle in system, and that system couldn't accept any other payment method than blockchain-based digital wallet. 
