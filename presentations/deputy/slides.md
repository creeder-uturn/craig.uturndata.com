# The Confused Deputy Problem (AWS IAM)

---

## Who am I?

---

Craig Reeder

---

Lead Cloud Engineer @
*Uturn Data Solutions*

---

## What is it?

---

TODO: Wikipedia definition here

---

## In less formal terms:

---

When a trusted neutral party is convinced to do bad things on behalf of the attacker

---

## Simple Non-Technical Example:

---

You give your friend a key to your house just in case

---

While on vacation, an attacker texts your friend

---

Hi friend! I need something valuable I left at home accidentally. Can you mail it to me at my hotel, here's the address

---

In this example, your friend is the confused deputy

---

## Real world example using AWS

---

You pay for a cloud management platform

Note: Real world software: CloudCheckr

---

As part of the onboarding process, you provide the ID for an identity the management platform can use

Note: The ID for this identity is not considered a secret - it is like a username

---

AWS handles authentication, you just provide the account ID that you trust (the deputy)

---

The situation now: the Cloud Management Platform has full admin to your AWS environment, you trust them

---

An attacker hires the same cloud management platform

---

As part of their onboarding process, they provide the ID for your identity

---

As you've set up the authentication for your onboarding, the deputy is able to authenticate to your environment

---

The attacker now has access to your environment through the confused deputy (the cloud management platform)

---

## Solutions

---

There's a lot of potential solutions to the confused deputy problem

---

I want to talk about the way that AWS addresses this

---

## External ID

---

External ID is an identifier provided by the deputy as part of the onboarding process

---

The external ID has one requirement:

---

The external ID needs to be unique per customer

---

This external ID is *not* a secret

Note: This is a big pet peeve of mine

---

This identifier is an "intent" token, it indicates the intent of the deputy

---

A great external ID is the customer number/id within the deputy's system

---

---

?
