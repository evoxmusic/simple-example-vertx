package com.qovery.example

import io.vertx.core.AbstractVerticle
import io.vertx.core.Promise
import io.vertx.core.json.JsonObject
import io.vertx.ext.web.client.WebClient
import io.vertx.ext.web.client.WebClientOptions
import io.vertx.ext.web.codec.BodyCodec

class MainVerticle : AbstractVerticle() {

  override fun start(startPromise: Promise<Void>) {
    val api = "api.chucknorris.io"
    val jokePath = "/jokes/random"
    val chuckApiClient = WebClient.create(vertx, WebClientOptions().setDefaultHost(api))

    vertx
      .createHttpServer()
      .requestHandler { req ->
        chuckApiClient.get(jokePath).`as`(BodyCodec.jsonObject()).send { ar ->
          if (ar.succeeded()) {
            val joke = ar.result().body().getString("value")
            req.response()
              .putHeader("content-type", "application/json")
              .end(JsonObject().put("joke", joke).encodePrettily())
          } else {
            println(ar.cause())
            req.response()
              .putHeader("content-type", "application/json")
              .end(JsonObject().put("joke", "Chuck Norris has just broken the connection to his API").encodePrettily())
          }
        }

      }
      .listen(8888) { http ->
        if (http.succeeded()) {
          startPromise.complete()
          println("HTTP server started on port 8888")
        } else {
          startPromise.fail(http.cause());
        }
      }
  }
}
