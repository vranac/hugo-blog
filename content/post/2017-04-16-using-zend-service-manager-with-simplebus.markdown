---
date: 2017-04-16T12:58:18+02:00
draft: false
title: Using Zend Service Manager with Simplebus
categories:
    - php
    - CQRS
    - EventBus
    - DIC
tags:
    - php
    - CQRS
    - EventBus
    - DIC
    - Zend Service Manager
---

We are currently working on a project that is evoliving in such a way that
using a messagebus would simplify code a lot, and would help us deliver
higher quality in less time. After looking around on packagist for
available event/command busses, I decided to try out the [SimpleBus][simplebus].
The docs are a bit sparse, they do give you all the necessary information, and
it is a quick setup.

We use [Zend Service Manager][zend-service-manager] as DIC and it is fairly
 straight forward to implement it.

Following the example from the docs, first you would declare your event

{{< codecaption lang="php" title="Event UserRegistered.php" >}}
<?php

class UserRegistered
{
    private $userId;

    public function __construct(string $userId)
    {
        $this->userId = $userId;
    }

    public function userId()
    {
        return $this->userId;
    }
}
{{< /codecaption >}}

Then your subscriber

{{< codecaption lang="php" title="Subscriber SendWelcomeMailWhenUserRegistered.php" >}}
<?php

class SendWelcomeMailWhenUserRegistered
{
    public function __invoke($message)
    {
        print "received {$message->userId()}" . PHP_EOL;
    }
}
{{< /codecaption >}}

And now for the important part, you would create a factory for
`ServiceLocatorAwareCallableResolver` in which it is instantiated with
a service locator callable that will instantiate the subscriber service
when needed with Zend Service Manager as shown on lines 20-22

{{< codecaption lang="php" title="Factory ServiceLocatorAwareCallableResolverFactory" >}}
<?php

class ServiceLocatorAwareCallableResolverFactory implements FactoryInterface
{
    /**
     * Create a ServiceLocatorAwareCallableResolver object instance
     *
     * @param  ContainerInterface $container
     * @param  string $requestedName
     * @param  null|array $options
     * @return ServiceLocatorAwareCallableResolver
     * @throws ServiceNotFoundException if unable to resolve the service.
     * @throws ServiceNotCreatedException if an exception is raised when
     *     creating a service.
     * @throws ContainerException if any other error occurs
     */
    public function __invoke(ContainerInterface $container, $requestedName, array $options = null) : ServiceLocatorAwareCallableResolver
    {
        return new ServiceLocatorAwareCallableResolver(
            function ($serviceId) use ($container) {
                return $container->get($serviceId);
            }
        );
    }
}
{{< /codecaption >}}

Add the factory and class in the Service Manager configuration

{{< codecaption lang="php" >}}
<?php

$serviceManager = new ServiceManager([
    'factories' => [
        ServiceLocatorAwareCallableResolver::class => ServiceLocatorAwareCallableResolverFactory::class
    ],
]);
{{< /codecaption >}}

Then put together the example as described in docs

{{< codecaption lang="php" >}}
<?php

$eventBus = new MessageBusSupportingMiddleware();
$eventBus->appendMiddleware(new FinishesHandlingMessageBeforeHandlingNext());

// Provide a map of event names to callables. You can provide actual callables, or lazy-loading ones.
$eventSubscribersByEventName = [
    UserRegistered::class => [
        SendWelcomeMailWhenUserRegistered::class,
        SendWelcomeMailWhenUserRegisteredAndSomething::class
    ]
];
{{< /codecaption >}}

With a slight difference when declaring a subscriber collection, on line 5
Service Manager is used to resolve the `ServiceLocatorAwareCallableResolver` which
will inject it with callable setup to resolve the requested subscribers

{{< codecaption lang="php" >}}
<?php

$eventSubscriberCollection = new CallableCollection(
    $eventSubscribersByEventName,
    $serviceManager->get(ServiceLocatorAwareCallableResolver::class)
);
{{< /codecaption >}}

Rest is identical to the example from the docs

{{< codecaption lang="php" >}}
<?php

$eventNameResolver = new ClassBasedNameResolver();

$eventSubscribersResolver = new NameBasedMessageSubscriberResolver(
    $eventNameResolver,
    $eventSubscriberCollection
);

$eventBus->appendMiddleware(
    new NotifiesMessageSubscribersMiddleware(
        $eventSubscribersResolver
    )
);

$event = new UserRegistered('some-user-id');
$eventBus->handle($event);
{{< /codecaption >}}

So when the script is run, you get a nice output of the user id

{{< codecaption lang="bash" >}}
➜  application git:(master) ✗ php event-bus.php
received some-user-id
{{< /codecaption >}}

[simplebus]: https://github.com/SimpleBus/MessageBus
[zend-service-manager]: https://docs.zendframework.com/zend-servicemanager/
