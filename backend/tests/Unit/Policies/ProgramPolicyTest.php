<?php

use App\Models\Program;
use App\Models\User;
use App\Policies\ProgramPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->policy = new ProgramPolicy;
    $this->program = Program::factory()->create();
});

it('allows any authenticated user to view programs', function () {
    $user = User::factory()->create();

    expect($this->policy->viewAny($user))->toBeTrue()
        ->and($this->policy->view($user, $this->program))->toBeTrue();
});

it('only allows admins to create, update, and delete programs', function () {
    $admin = User::factory()->admin()->create();
    $user = User::factory()->create();

    expect($this->policy->create($admin))->toBeTrue()
        ->and($this->policy->update($admin, $this->program))->toBeTrue()
        ->and($this->policy->delete($admin, $this->program))->toBeTrue()
        ->and($this->policy->create($user))->toBeFalse()
        ->and($this->policy->update($user, $this->program))->toBeFalse()
        ->and($this->policy->delete($user, $this->program))->toBeFalse();
});
